#!/usr/bin/env python3
# written by Ungbin_Oh
# project : [AWP] AI-Assistant-Workflow-Publishing
# created : 2026-11-02
# updated : 2026-11-02
#
# set-thread-name.py <socket> <thread_id> <name> — set a Codex thread name on the shared app-server daemon.
#
# The daemon's control socket (~/.codex/app-server-control/app-server-control.sock) speaks WebSocket
# (HTTP upgrade to ws://localhost/rpc, then JSON-RPC in text frames). `codex app-server proxy` only relays
# raw bytes, so plain JSON lines get "Broken pipe" (AWP-trace410). This script does the WebSocket handshake
# and framing with the standard library only.
# When the TUI runs on the same daemon (`codex --remote unix://`), the daemon sends thread/name/updated to it
# and the open screen changes at once.
# Exit 0 = the daemon answered thread/name/set with a result. Anything else = non-zero (the hook falls back).

import base64
import json
import os
import socket
import struct
import sys
import time


def send_text(sock, text):
    # Client frames must be masked (RFC 6455)
    payload = text.encode("utf-8")
    mask = os.urandom(4)
    header = bytearray([0x81])
    n = len(payload)
    if n < 126:
        header.append(0x80 | n)
    elif n < 65536:
        header.append(0x80 | 126)
        header += struct.pack(">H", n)
    else:
        header.append(0x80 | 127)
        header += struct.pack(">Q", n)
    masked = bytes(b ^ mask[i % 4] for i, b in enumerate(payload))
    sock.sendall(bytes(header) + mask + masked)


def recv_exact(sock, n):
    data = b""
    while len(data) < n:
        chunk = sock.recv(n - len(data))
        if not chunk:
            raise ConnectionError("socket closed")
        data += chunk
    return data


def recv_frame(sock):
    # Returns (opcode, payload). Server frames are not masked
    b1, b2 = recv_exact(sock, 2)
    opcode = b1 & 0x0F
    n = b2 & 0x7F
    if n == 126:
        n = struct.unpack(">H", recv_exact(sock, 2))[0]
    elif n == 127:
        n = struct.unpack(">Q", recv_exact(sock, 8))[0]
    if b2 & 0x80:
        mask = recv_exact(sock, 4)
        data = bytes(b ^ mask[i % 4] for i, b in enumerate(recv_exact(sock, n)))
    else:
        data = recv_exact(sock, n)
    return opcode, data


def main():
    sock_path, thread_id, name = sys.argv[1], sys.argv[2], sys.argv[3]
    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    s.settimeout(10)
    s.connect(os.path.realpath(os.path.expanduser(sock_path)))

    key = base64.b64encode(os.urandom(16)).decode()
    s.sendall((
        "GET /rpc HTTP/1.1\r\nHost: localhost\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n"
        f"Sec-WebSocket-Key: {key}\r\nSec-WebSocket-Version: 13\r\n\r\n"
    ).encode())
    head = b""
    while b"\r\n\r\n" not in head:
        chunk = s.recv(4096)
        if not chunk:
            print("handshake: socket closed"); return 2
        head += chunk
    status = head.split(b"\r\n", 1)[0].decode(errors="replace")
    print("handshake:", status)
    if " 101 " not in status + " ":
        return 2

    send_text(s, json.dumps({"method": "initialize", "id": 1,
                             "params": {"clientInfo": {"name": "alfred", "version": os.environ.get("ALFRED_VERSION", "0")}}}))
    deadline = time.time() + 10
    sent_set = False
    while time.time() < deadline:
        opcode, data = recv_frame(s)
        if opcode == 0x9:                       # ping → pong (masked)
            s.sendall(bytes([0x8A, 0x80 | len(data)]) + b"\0\0\0\0" + data)
            continue
        if opcode == 0x8:
            print("closed by daemon"); return 3
        if opcode != 0x1:
            continue
        text = data.decode("utf-8", errors="replace")
        print(text[:300])
        msg = json.loads(text)
        if msg.get("id") == 1 and not sent_set:
            send_text(s, json.dumps({"method": "initialized"}))
            send_text(s, json.dumps({"method": "thread/name/set", "id": 2,
                                     "params": {"threadId": thread_id, "name": name}}))
            sent_set = True
        elif msg.get("id") == 2:
            return 0 if "result" in msg else 4
    return 5


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as error:
        print("error:", error)
        sys.exit(1)
