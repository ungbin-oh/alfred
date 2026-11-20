#!/usr/bin/env python3
# written by Ungbin_Oh
# created : 2026-11-20
# updated : 2026-11-20
#
# Alfred — trace-answer Stop hook (the full answer goes under the trace entry)
#
# Each time the assistant finishes a reply, this takes the final answer of that turn from the session
# transcript and puts it right below the trace entry written in that turn, as a folded quote box:
#   > [!quote]- Full answer · HH:MM          (Korean workspaces: 답 전문 · HH:MM)
#   > (the answer, every line prefixed with "> ")
# Why: rules §8 keeps the trace lean (the assistant no longer writes its answer out a second time), so
# the answer itself would be nowhere in the workspace. The hook copies it; the assistant writes nothing extra.
# Only the final answer is copied — no reasoning, no text written between tool calls.
#
# Which trace entry:
#   1. The last "## <CODE>-trace<N> " header this session wrote in this turn's tool calls. The box goes
#      right below that entry. Traces written by another session are never touched.
#   2. No trace entry written this turn: the end of the newest trace file of the project this session
#      last attached to (the box title says so).
#   3. This session has not written a trace yet (the boot briefing, for one): nothing happens.
#
# Works on both transcripts: Claude Code (lines with "message") and Codex (rollout lines with "payload").
# Input: the hook's stdin JSON (transcript_path · cwd · session_id, and last_assistant_message when given).
# Outside an Alfred workspace (no .alfred/workspace above cwd) nothing happens.
# Off switch: a file .alfred/trace-answer whose content is "off".
# State (last answer attached, last project): <system temp>/alfred-trace-answer/<session id>.json
# Errors are appended to <system temp>/alfred-trace-answer/error.log and never stop the reply.
# Try it without writing: python3 trace-answer.py --dry-run <transcript.jsonl> <workspace root>

import hashlib
import json
import os
import re
import sys
import tempfile
import time
from datetime import datetime
from pathlib import Path

STATE_DIR = Path(tempfile.gettempdir()) / "alfred-trace-answer"

# A trace entry header inside a tool call. In a tool input the line may start the text, follow a real
# newline or an escaped one ("\\n", Codex passes scripts as strings), and carry a "+" (apply_patch).
TRACE_HEADER_IN_TOOL_INPUT = re.compile(r"(?:^|\n|\\n)\+?## ([A-Z][A-Z0-9]{1,7})-trace(\d+) ")
CLAUDE_WRITING_TOOLS = {"Bash", "Edit", "Write", "MultiEdit"}
CODEX_TOOL_CALL_TYPES = {"custom_tool_call", "function_call", "local_shell_call"}

BOX_TITLES = {
    "en": ("Full answer · %s", "Full answer · %s %s · no trace entry this turn"),
    "ko": ("답 전문 · %s", "답 전문 · %s %s · trace 항목 없이 붙음"),
}


def find_workspace_root(start_dir):
    directory = Path(start_dir).resolve()
    for candidate in [directory] + list(directory.parents):
        if (candidate / ".alfred" / "workspace").is_file():
            return candidate
    return None


def workspace_language(workspace_root):
    try:
        marker_text = (workspace_root / ".alfred" / "workspace").read_text(encoding="utf-8")
    except OSError:
        return "en"
    match = re.search(r"^language:\s*(\w+)", marker_text, re.MULTILINE)
    return match.group(1) if match and match.group(1) in BOX_TITLES else "en"


def is_switched_off(workspace_root):
    try:
        return (workspace_root / ".alfred" / "trace-answer").read_text(encoding="utf-8").strip() == "off"
    except OSError:
        return False


def read_transcript_lines(transcript_path):
    entries = []
    with open(transcript_path, encoding="utf-8") as transcript_file:
        for line in transcript_file:
            try:
                entry = json.loads(line)
            except ValueError:
                continue
            if isinstance(entry, dict):
                entries.append(entry)
    return entries


def all_strings_in(value):
    if isinstance(value, str):
        yield value
    elif isinstance(value, dict):
        for inner in value.values():
            yield from all_strings_in(inner)
    elif isinstance(value, list):
        for inner in value:
            yield from all_strings_in(inner)


def trace_headers_in(tool_inputs):
    """Every (code, number) trace header found in the tool inputs, in the order written."""
    headers = []
    for tool_input in tool_inputs:
        for text in all_strings_in(tool_input):
            for match in TRACE_HEADER_IN_TOOL_INPUT.finditer(text):
                headers.append((match.group(1), int(match.group(2))))
    return headers


# ---- Claude Code transcript ------------------------------------------------------------------------

def claude_blocks(entry):
    content = entry["message"].get("content")
    if isinstance(content, str):
        return [{"type": "text", "text": content}]
    return [block for block in (content or []) if isinstance(block, dict)]


def read_claude_turn(entries):
    """Returns (final answer, key of the answer, tool inputs of the turn)."""
    main_entries = [
        entry for entry in entries
        if not entry.get("isSidechain")
        and entry.get("type") in ("user", "assistant")
        and isinstance(entry.get("message"), dict)
    ]
    turn_start_index = 0
    for index in range(len(main_entries) - 1, -1, -1):
        entry = main_entries[index]
        if entry["type"] != "user" or entry.get("isMeta"):
            continue
        block_types = {block.get("type") for block in claude_blocks(entry)}
        if "text" in block_types and "tool_result" not in block_types:
            turn_start_index = index
            break
    turn_entries = main_entries[turn_start_index:]

    # The final answer: the assistant text at the very end of the turn, back to the last tool call
    text_pieces, answer_key = [], None
    for entry in reversed(turn_entries):
        if entry["type"] != "assistant":
            break
        blocks = claude_blocks(entry)
        if any(block.get("type") == "tool_use" for block in blocks):
            break
        texts = [block.get("text", "") for block in blocks if block.get("type") == "text"]
        if texts and answer_key is None:
            answer_key = entry.get("uuid")
        text_pieces[0:0] = texts
    answer_text = "\n\n".join(piece.strip("\n") for piece in text_pieces if piece.strip())

    tool_inputs = []
    for entry in turn_entries:
        if entry["type"] != "assistant":
            continue
        for block in claude_blocks(entry):
            if block.get("type") == "tool_use" and block.get("name") in CLAUDE_WRITING_TOOLS:
                tool_inputs.append(block.get("input"))
    return answer_text, answer_key, tool_inputs


# ---- Codex rollout ---------------------------------------------------------------------------------

def read_codex_turn(entries, turn_id):
    """Returns (final answer, key of the answer, tool inputs of the turn)."""
    turn_start_index = 0
    for index in range(len(entries) - 1, -1, -1):
        payload = entries[index].get("payload")
        if entries[index].get("type") != "event_msg" or not isinstance(payload, dict):
            continue
        if payload.get("type") != "task_started":
            continue
        started_turn_id = (payload.get("turn_attribution") or {}).get("turn_id")
        if turn_id and started_turn_id and started_turn_id != turn_id:
            continue
        turn_start_index = index
        break

    answer_text, tool_inputs = "", []
    for entry in entries[turn_start_index:]:
        payload = entry.get("payload")
        if entry.get("type") != "response_item" or not isinstance(payload, dict):
            continue
        if payload.get("type") == "message" and payload.get("role") == "assistant":
            texts = [
                block.get("text", "")
                for block in payload.get("content") or []
                if isinstance(block, dict) and block.get("type") == "output_text"
            ]
            if any(text.strip() for text in texts):
                answer_text = "\n\n".join(text.strip("\n") for text in texts if text.strip())
        elif payload.get("type") in CODEX_TOOL_CALL_TYPES:
            tool_inputs.append({key: value for key, value in payload.items() if key not in ("id", "call_id")})
    return answer_text, turn_id, tool_inputs


# ---- Workspace side --------------------------------------------------------------------------------

def project_dir_of_code(workspace_root, project_code):
    """The project folder whose log.md frontmatter says `code: <project_code>`."""
    for log_path in (workspace_root / "project-logs").rglob("log.md"):
        try:
            head = log_path.read_text(encoding="utf-8")[:4000]
        except OSError:
            continue
        if not head.startswith("---"):
            continue
        frontmatter = head.split("\n---", 1)[0]
        if re.search(r"^code:\s*%s\s*$" % re.escape(project_code), frontmatter, re.MULTILINE):
            return log_path.parent
    return None


def trace_files_newest_first(project_dir):
    return sorted((project_dir / "trace").glob("*.md"), reverse=True)


def quote_box(answer_text, title):
    lines = ["> [!quote]- " + title]
    for line in answer_text.split("\n"):
        lines.append(("> " + line).rstrip())
    return "\n".join(lines)


def insert_below_trace_entry(trace_text, project_code, trace_number, box_text):
    """trace_text with the box put right below that entry (before the next "## " header). None if the entry is not there."""
    lines = trace_text.split("\n")
    header_prefix = "## %s-trace%d " % (project_code, trace_number)
    header_index = None
    for index, line in enumerate(lines):
        if line.startswith(header_prefix):
            header_index = index
    if header_index is None:
        return None
    entry_end_index = len(lines)
    for index in range(header_index + 1, len(lines)):
        if lines[index].startswith("## "):
            entry_end_index = index
            break
    entry_lines = lines[:entry_end_index]
    while entry_lines and entry_lines[-1].strip() == "":
        entry_lines.pop()
    return "\n".join(entry_lines + ["", box_text, ""] + lines[entry_end_index:])


def write_atomically(path, text):
    temp_path = path.with_name(path.name + ".trace-answer.tmp")
    with open(temp_path, "w", encoding="utf-8", newline="") as temp_file:
        temp_file.write(text)
    os.replace(temp_path, path)


def read_text_keeping_newlines(path):
    with open(path, encoding="utf-8", newline="") as text_file:
        return text_file.read()


def load_state(state_path):
    try:
        return json.loads(state_path.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return {}


def read_turn(transcript_path, turn_id):
    entries = read_transcript_lines(transcript_path)
    if any("payload" in entry for entry in entries[:50]):
        return read_codex_turn(entries, turn_id)
    return read_claude_turn(entries)


def run(transcript_path, workspace_root, session_id, turn_id, answer_from_hook_input, dry_run):
    answer_text, answer_key, tool_inputs = "", None, []
    # The hook can fire before the last line of the answer has landed in the transcript: wait a little and reread
    for _attempt in range(10):
        answer_text, answer_key, tool_inputs = read_turn(transcript_path, turn_id)
        if answer_text or answer_from_hook_input or dry_run:
            break
        time.sleep(0.2)
    if answer_from_hook_input and answer_from_hook_input.strip():
        answer_text = answer_from_hook_input.strip("\n")
    if not answer_text.strip():
        return "no answer text"

    answer_key = answer_key or hashlib.sha1(answer_text.encode("utf-8")).hexdigest()
    state_path = STATE_DIR / ("%s.json" % (session_id or "unknown"))
    state = load_state(state_path)
    if state.get("last_answer_key") == answer_key and not dry_run:
        return "already attached"

    title_with_entry, title_without_entry = BOX_TITLES[workspace_language(workspace_root)]
    now = datetime.now()
    target_path, new_text, box_text, where, project_code = None, None, None, None, None

    # 1. Below the last trace entry this session wrote in this turn (it has to exist in a trace file)
    for header_code, trace_number in reversed(trace_headers_in(tool_inputs)):
        project_dir = project_dir_of_code(workspace_root, header_code)
        if not project_dir:
            continue
        box_text = quote_box(answer_text, title_with_entry % now.strftime("%H:%M"))
        for trace_path in trace_files_newest_first(project_dir)[:3]:
            inserted = insert_below_trace_entry(
                read_text_keeping_newlines(trace_path), header_code, trace_number, box_text
            )
            if inserted is not None:
                target_path, new_text, project_code = trace_path, inserted, header_code
                where = "below %s-trace%d" % (header_code, trace_number)
                break
        if target_path is not None:
            break

    # 2. No entry this turn: the end of the newest trace file of the project last attached to
    if target_path is None and state.get("project_code"):
        project_code = state["project_code"]
        project_dir = project_dir_of_code(workspace_root, project_code)
        trace_paths = trace_files_newest_first(project_dir) if project_dir else []
        if trace_paths:
            box_text = quote_box(
                answer_text, title_without_entry % (now.strftime("%Y-%m-%d"), now.strftime("%H:%M"))
            )
            target_path = trace_paths[0]
            new_text = read_text_keeping_newlines(target_path).rstrip("\n") + "\n\n" + box_text + "\n"
            where = "end of the newest %s trace file" % project_code

    if target_path is None:
        return "no trace to attach to"

    if dry_run:
        print("target: %s (%s)" % (target_path, where))
        print(box_text)
        return "dry-run"

    write_atomically(target_path, new_text)
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    state_path.write_text(
        json.dumps({"last_answer_key": answer_key, "project_code": project_code}, ensure_ascii=False),
        encoding="utf-8",
    )
    return "attached: %s" % where


def main():
    if len(sys.argv) >= 4 and sys.argv[1] == "--dry-run":
        print(run(sys.argv[2], Path(sys.argv[3]).resolve(), "dry-run", None, None, True))
        return
    try:
        hook_input = json.loads(sys.stdin.buffer.read().decode("utf-8") or "{}")
    except ValueError:
        hook_input = {}
    transcript_path = hook_input.get("transcript_path") or ""
    if not transcript_path or not os.path.isfile(transcript_path):
        return
    workspace_root = find_workspace_root(hook_input.get("cwd") or os.getcwd())
    if workspace_root is None or is_switched_off(workspace_root):
        return
    run(
        transcript_path,
        workspace_root,
        hook_input.get("session_id"),
        hook_input.get("turn_id"),
        hook_input.get("last_assistant_message"),
        False,
    )


if __name__ == "__main__":
    try:
        main()
    except Exception as error:  # a hook error must never stop the reply
        try:
            STATE_DIR.mkdir(parents=True, exist_ok=True)
            with open(STATE_DIR / "error.log", "a", encoding="utf-8") as error_log:
                error_log.write("%s %r\n" % (datetime.now().isoformat(timespec="seconds"), error))
        except OSError:
            pass
    sys.exit(0)
