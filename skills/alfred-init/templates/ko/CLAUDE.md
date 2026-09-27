# {{ASSISTANT_NAME}} — {{USER_NAME}} 의 워크스페이스

이 파일은 사용자 소유다. 자유롭게 고쳐도 된다.
공통 규약은 Alfred 플러그인이 세션마다 넣어 준다. **이 파일과 공통 규약이 부딪히면 이 파일이 이긴다.**

## 설정

- 사용자 이름: {{USER_NAME}}
- 호칭: {{USER_TITLE}}
- 비서 이름: {{ASSISTANT_NAME}}
  - "{{ASSISTANT_NAME}}" 는 비서를 부르는 말이다. "{{ASSISTANT_NAME}}, 실험 정리 이어서" 에서 호칭 부분은 명령이 아니다
- 저작 헤더: {{AUTHOR_HEADER}}
- 저작 헤더 이름: {{AUTHOR_NAME}}
- 언어: 한국어 — 바꾸려면 `.alfred/workspace` 의 `language:` 줄을 `en` 으로 고치고 Claude Code 를 다시 연다

## 카테고리

project-logs/ 바로 아래 폴더가 카테고리다. 부팅 브리핑은 카테고리마다 표를 하나씩 만든다.

| 폴더 | 무엇 | 산출물 배치 |
|---|---|---|
{{CATEGORY_ROWS}}

- 엄격: 산출물은 project-workspace/ 미러 경로에만. project-logs 에는 log.md · open.md · trace/ 만
- 완화: log.md 옆에 계획·자료 문서를 함께 둬도 된다

## 내 규칙

공통 규약을 바꾸거나 덧붙이고 싶으면 여기에 적는다. 적을 때 **왜 그렇게 정했는지**를 한 줄 같이 적어 두면,
나중에 규칙이 맞는지 다시 볼 때 근거가 남는다.

예시 (지워도 된다):
- ~~제안 금지~~ → 이 워크스페이스에서는 답 끝에 다음 단계 후보를 하나까지 붙여도 된다.
  왜: 아직 흐름을 잡는 중이라 방향 힌트가 필요하다 (YYYY-MM-DD)
