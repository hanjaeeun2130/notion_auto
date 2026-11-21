---
name: gws-skill
description: Google Workspace CLI(gws)로 사용자의 Google Calendar, Gmail, Drive, Sheets, Docs, Slides, Tasks, Chat, Forms, Meet, Apps Script를 터미널에서 조회하고 다룹니다. Google Workspace에서 무언가를 확인·검색·목록 조회·요약·생성·수정·업로드·공유·발송해달라는 요청이면 "gws"라는 말이 없어도 이 skill을 쓰세요. 예: "오늘 일정 보여줘", "진흥원 캘린더 이번 주 일정", "안 읽은 메일 요약", "메일 초안 만들어줘", "드라이브에 파일 올려줘", "시트에 행 추가", "구글 문서에 내용 붙여줘", "gws 명령어 알려줘". gws 설치, OAuth 로그인 설정·복구, gws 기능 설명에도 씁니다. 인증 정보는 skill 폴더의 .env에서 읽으므로 어느 폴더에서든 동작합니다.
---

# gws-skill

`gws` CLI(npm `@googleworkspace/cli`, 0.22.5에서 테스트)로 Google Workspace를 다룹니다. 이 skill에는 skill 폴더의 `.env`에서 OAuth 인증 정보를 읽는 실행 스크립트, 사전 점검 스크립트, 서비스별 사용법 문서가 들어 있습니다.

아래 경로는 이 skill 폴더(이 파일이 있는 폴더) 기준입니다.

## 1. 모든 명령은 실행 스크립트로 실행

실행 스크립트가 `.env`(클라이언트 ID/secret, 프로젝트 ID)를 읽고 UTF-8을 맞춰주므로, 어느 작업 폴더에서든 명령이 동작합니다.

| 셸 | 호출 |
|---|---|
| Bash (권장: JSON을 그대로 쓸 수 있음) | `bash <skill>/scripts/gws.sh <인자>` |
| PowerShell | `& '<skill>\scripts\gws.ps1' <인자>` |

PowerShell에서는 `powershell -File`이 아니라 `&`로 스크립트를 호출하세요. 프로세스를 한 번 더 거치면 `--params` JSON 안의 따옴표가 사라져서 종료 코드 3("key must be a string")으로 실패합니다. 또 PowerShell에서는 JSON 따옴표를 이스케이프해야 합니다: `'{\"pageSize\": 5}'`. Bash는 `'{"pageSize": 5}'`를 그대로 받으므로 Bash를 권장합니다.

모든 호출은 stderr에 `Using keyring backend: keyring`을 출력합니다. 의미 없는 메시지이므로, 출력을 파싱할 때는 stderr를 버리세요(`2>/dev/null`).

## 2. 세션마다 한 번 사전 점검

첫 실제 명령 전에 `bash <skill>/scripts/preflight.sh`(또는 `scripts/preflight.ps1`)를 실행합니다. Node, gws, `.env`, 로그인 토큰을 확인해 `READY` 또는 부족한 항목을 출력합니다. 아무것도 설치하거나 바꾸지 않습니다.

READY가 아니면 `references/setup-auth.md`를 읽고 실패한 항목을 해결하세요. 소프트웨어 설치나 로그인은 사용자의 PC나 계정을 바꾸는 일이므로, 무엇을 할지 말하고 먼저 동의를 받으세요. 로그인하면 Google 동의 화면이 열리고, 로그인과 허용 클릭은 사용자가 직접 해야 합니다.

## 3. 명령 만들기

서비스에 맞는 참고 문서를 골라 읽으세요. 정확한 옵션, 예시, 주의할 점이 들어 있습니다.

| 요청 내용 | 읽을 문서 |
|---|---|
| 캘린더, 일정, 빈 시간 | `references/calendar.md` |
| Gmail: 검색, 읽기, 요약, 초안, 발송, 답장, 라벨 | `references/gmail.md` |
| Drive: 목록, 검색, 업로드, 다운로드, 내보내기, 공유 | `references/drive.md` |
| Sheets, Docs, Slides | `references/sheets-docs-slides.md` |
| Tasks, People, Chat, Forms, Keep, Meet, Classroom, Apps Script, workflow 헬퍼 | `references/other-services.md` |
| 설치, 로그인, 권한(scope), `.env`, 오류 | `references/setup-auth.md` |
| "gws로 뭘 할 수 있어?" 전체 개요 | `references/command-catalog.md` |

명령 형식:

```
gws <서비스> +<헬퍼> [옵션]                          # 헬퍼: 자주 하는 작업의 단축 명령
gws <서비스> <리소스> [하위 리소스] <메서드> --params '<쿼리 JSON>' [--json '<본문 JSON>']
gws schema <서비스.리소스.메서드>                     # 원본 메서드의 파라미터 확인
```

맞는 헬퍼(`+agenda`, `+triage`, `+send`, `+append`, `+upload` 등)가 있으면 헬퍼를 쓰고, 없으면 원본 API를 씁니다. 옵션이 확실하지 않으면 `<명령> --help`를 실행하세요. 빠르고 읽기 전용입니다. 사람이 볼 결과는 `--format table`을 붙이고, 파싱할 결과는 JSON 그대로 둡니다. `--params`에 `fields`를 넣으면 응답이 작아집니다.

## 4. 안전: 읽기는 자유롭게, 변경 전에는 확인

읽기는 해가 없으므로 바로 실행합니다: `list`, `get`, `+agenda`, `+triage`, `+read`, `sheets +read`, `--help`, `schema`, `auth status`.

쓰기·발송·공유·삭제는 사용자의 실제 데이터나 다른 사람의 메일함에 영향을 주고, 되돌릴 수 없는 경우도 있습니다. 이런 명령은:

1. 실행할 명령과 바뀌는 내용을 정확히 보여줍니다.
2. 명령이 지원하면 먼저 `--dry-run`으로 실행하고(헬퍼는 모두 지원) 결과를 보여줍니다.
3. 사용자가 그 명령을 승인한 뒤에만 실제로 실행합니다.

메일은 특히 조심하세요. 초안을 만들고(`+send --draft`, `+reply --draft`, 또는 `users drafts create`), 받는 사람·제목·본문을 보여준 뒤, 사용자가 그 초안을 승인했을 때만 발송합니다. 메일과 파일은 `delete`보다 `trash`를 쓰세요. 사용자가 명시하지 않은 일정, 파일, 메일은 수정하거나 삭제하지 마세요.

작업 중인 프로젝트에 자체 승인 규칙이 있으면(예: 명령 미리보기를 요구하는 CLAUDE.md) 그 규칙도 따릅니다.

## 5. 결과 해석

| 종료 코드 | 의미 | 대응 |
|---|---|---|
| 0 | 성공 | 결과 보고 |
| 1 | API 오류 | JSON의 `error.message`를 확인합니다. 403 `accessNotConfigured`는 API가 꺼진 상태이니 메시지의 `enable_url`을 열거나 `gcloud services enable <api>`를 실행하고, 약 10초 뒤 다시 시도합니다 |
| 2 | 인증 오류 | 토큰 없음·만료 또는 권한 미부여 → `references/setup-auth.md` |
| 3 | 검증 오류 | 잘못된 옵션이나 JSON (주로 PowerShell 따옴표 문제) |
| 4 | discovery 오류 | API 스키마를 못 가져옴. 네트워크 확인 후 재시도 |
| 5 | 내부 오류 | `GOOGLE_WORKSPACE_CLI_LOG=gws=debug`로 다시 실행 |

결과는 사용자의 언어로 간단히 보고합니다: 찾은 것이나 한 일, 그리고 만든 항목의 ID와 링크(Drive 파일: `https://drive.google.com/file/d/<id>`, Docs: `https://docs.google.com/document/d/<id>`, Sheets: `https://docs.google.com/spreadsheets/d/<id>`).

## 6. 기본값

- 시간대: `.env`의 `GWS_TIMEZONE`(Asia/Seoul). `+agenda`에는 `--timezone`을 넘기고, 원본 calendar 호출에는 오프셋이 붙은 RFC3339 시간(`2026-11-21T09:00:00+09:00`)을 씁니다.
- 부여된 권한(현재 로그인): calendar, gmail.modify, drive, spreadsheets. Docs와 Slides API는 drive 권한으로도 동작합니다. Tasks, People, Chat, Forms, Keep, Meet, Classroom, Apps Script는 권한을 추가해야 하니 쓰기 전에 `references/setup-auth.md`를 보세요.
