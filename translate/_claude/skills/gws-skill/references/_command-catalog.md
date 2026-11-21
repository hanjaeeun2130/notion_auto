# gws 명령 카탈로그 (gws 0.22.5)

"gws로 뭘 할 수 있어?"에 답할 때 씁니다. 자세한 내용은 서비스별 참고 문서에 있습니다.

현재 로그인 기준 사용 가능 여부: ✅ 권한 있음 · 🔓 drive 권한으로 동작 · 🔒 API와 권한 추가 필요 (`setup-auth.md` 5절)

## 서비스

| 서비스 | 용도 | 사용 가능 |
|---|---|---|
| `calendar` | 캘린더, 일정 | ✅ |
| `gmail` | 읽기, 초안, 발송, 라벨 | ✅ |
| `drive` | 파일, 폴더, 공유 드라이브, 권한 | ✅ |
| `sheets` | 스프레드시트 | ✅ |
| `docs` | Google Docs | 🔓 |
| `slides` | 프레젠테이션 | 🔓 |
| `tasks` | 할 일 목록 | 🔒 |
| `people` | 연락처, 프로필 | 🔒 |
| `chat` | Chat 스페이스, 메시지 | 🔒 (Workspace) |
| `forms` | 설문, 응답 | 🔒 |
| `keep` | Keep 메모 | 🔒 (Workspace) |
| `meet` | Meet 공간, 회의 기록 | 🔒 |
| `classroom` | 수업, 과제 | 🔒 |
| `script` | Apps Script 프로젝트 | 🔒 |
| `workflow` (`wf`) | 여러 서비스를 묶은 헬퍼 | 사용하는 서비스에 따라 다름 |
| `admin-reports` (`reports`) | 감사·사용량 로그 | 관리자 전용 |
| `events`, `modelarmor` | Workspace 이벤트 구독, 콘텐츠 필터 | 🔒 |

## 헬퍼

| 명령 | 용도 | 종류 |
|---|---|---|
| `calendar +agenda` | 다가오는 일정 (`--today/--tomorrow/--week/--days N/--calendar`) | 읽기 |
| `calendar +insert` | 일정 만들기 (`--summary --start --end --location --attendee --meet`) | 쓰기 |
| `gmail +triage` | 안 읽은 메일 요약 (`--query --max --labels`) | 읽기 |
| `gmail +read` | 메일 본문·헤더 | 읽기 |
| `gmail +send` | 발송 (`--draft`면 초안 저장) | 발송 |
| `gmail +reply` / `+reply-all` / `+forward` | 스레드 답장 / 전달 (`--draft`) | 발송 |
| `gmail +watch` | Pub/Sub로 새 메일 실시간 수신 | 읽기 (Pub/Sub 리소스 생성) |
| `sheets +read` / `+append` | 범위 읽기 / 행 추가 | 읽기 / 쓰기 |
| `docs +write` | 텍스트 덧붙이기 | 쓰기 |
| `drive +upload` | 파일 업로드 | 쓰기 |
| `chat +send` | 메시지 보내기 | 쓰기 |
| `script +push` | 스크립트 파일 올리기 | 쓰기 |
| `workflow +standup-report` / `+meeting-prep` / `+weekly-digest` | 요약 | 읽기 |
| `workflow +email-to-task` / `+file-announce` | 메일→할 일 / 파일 공유 알림 | 쓰기 |

## 주요 리소스와 메서드

| 서비스 | 리소스 | 메서드 |
|---|---|---|
| calendar | `events` | list, get, instances, insert, quickAdd, update, patch, move, import, delete, watch |
| calendar | `calendarList`, `calendars`, `acl`, `freebusy`, `settings`, `colors` | 캘린더 목록, 공유, 빈 시간 |
| gmail | `users messages` | list, get, send, modify, batchModify, trash, untrash, delete, batchDelete, insert, import, attachments |
| gmail | `users drafts` | list, get, create, update, send, delete |
| gmail | `users` | getProfile, labels, threads, history, settings, watch, stop |
| drive | `files` | list, get, create, copy, update, download, export, delete, emptyTrash, watch, listLabels, modifyLabels |
| drive | `permissions`, `drives`, `comments`, `replies`, `revisions`, `changes`, `about` | 공유, 공유 드라이브, 댓글, 버전 |
| sheets | `spreadsheets` | create, get, batchUpdate, getByDataFilter |
| sheets | `spreadsheets values` | get, batchGet, update, batchUpdate, append, clear, batchClear (+ByDataFilter) |
| docs | `documents` | create, get, batchUpdate |
| slides | `presentations` | create, get, batchUpdate (+ pages) |
| tasks | `tasklists`, `tasks` | list, get, insert, update, patch, delete, move, clear |

## 공통 옵션

| 옵션 | 의미 |
|---|---|
| `--params <JSON>` | URL·쿼리 파라미터 |
| `--json <JSON>` | 요청 본문 |
| `--upload <PATH>` / `--upload-content-type` | 미디어 업로드 |
| `--output <PATH>` | 바이너리 응답 저장 |
| `--format json\|table\|yaml\|csv` | 출력 형식 |
| `--page-all`, `--page-limit N`, `--page-delay MS` | 페이지 넘기기 (NDJSON) |
| `--dry-run` | 로컬 검증만, 전송 안 함 |
| `--api-version` | API 버전 지정 |

## 인증 명령

`gws auth status` · `gws auth login -s <서비스들>` · `gws auth setup` (gcloud 필요, 0.22.5에서는 OAuth 클라이언트 생성 단계에서 멈춤) · `gws auth export [--unmasked]` · `gws auth logout`

## 종료 코드

0 성공 · 1 API 오류 · 2 인증 · 3 검증 · 4 discovery · 5 내부 오류
