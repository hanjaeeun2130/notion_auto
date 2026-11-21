# 기타 서비스와 workflow 헬퍼

따로 표시한 경우를 빼고, 이 서비스들은 GCP 프로젝트에서 API를 켜고 로그인할 때 권한을 추가해야 합니다(`setup-auth.md` 5절). 처음 쓸 때는 읽기 명령부터 실행하세요. 종료 코드 2나 403이 나오면 권한·API를 추가하고, 다시 로그인해야 한다고 사용자에게 알려주세요.

## Workflow 헬퍼 (`gws workflow ...`, 별칭 `wf`)

| 헬퍼 | 기능 | 필요 권한 | 종류 |
|---|---|---|---|
| `+standup-report` | 오늘 회의 + 남은 할 일 | calendar, tasks | 읽기 |
| `+meeting-prep [--calendar <ID>]` | 다음 일정의 안건, 참석자, 연결 문서 | calendar | 읽기 |
| `+weekly-digest` | 이번 주 회의 + 안 읽은 메일 수 | calendar, gmail | 읽기 |
| `+email-to-task --message-id <id> [--tasklist <ID>]` | Gmail 메일 → Google Tasks 항목 | gmail, tasks | 쓰기 |
| `+file-announce --file-id <id> --space spaces/<ID> [--message '<내용>']` | Drive 파일을 Chat 스페이스에 공유 | drive, chat | 쓰기 |

모두 `--format table`과 `--dry-run`을 지원합니다.

## Tasks (`tasks`)

| 작업 | 명령 | 종류 |
|---|---|---|
| 할 일 목록들 | `gws tasks tasklists list` | 읽기 |
| 목록 안 할 일 | `gws tasks tasks list --params '{"tasklist":"@default","showCompleted":false}'` | 읽기 |
| 추가 | `gws tasks tasks insert --params '{"tasklist":"@default"}' --json '{"title":"<제목>","due":"2026-11-30T00:00:00Z","notes":"<메모>"}'` | 쓰기 |
| 완료 처리 | `gws tasks tasks patch --params '{"tasklist":"@default","task":"<id>"}' --json '{"status":"completed"}'` | 쓰기 |

## People / 연락처 (`people`)

| 작업 | 명령 | 종류 |
|---|---|---|
| 내 연락처 | `gws people people connections list --params '{"resourceName":"people/me","personFields":"names,emailAddresses,phoneNumbers","pageSize":50}'` | 읽기 |
| 검색 | `gws people people searchContacts --params '{"query":"김","readMask":"names,emailAddresses"}'` | 읽기 |
| 그룹 | `gws people contactGroups list` | 읽기 |

## Chat (`chat`) — 보통 Workspace(회사) 계정 전용

| 작업 | 명령 | 종류 |
|---|---|---|
| 스페이스 | `gws chat spaces list` | 읽기 |
| 메시지 | `gws chat spaces messages list --params '{"parent":"spaces/<ID>"}'` | 읽기 |
| 보내기 | `gws chat +send --space spaces/<ID> --text '<내용>'` | 쓰기 (다른 사람에게 전달됨: 확인 필요) |

## Forms (`forms`)

| 작업 | 명령 | 종류 |
|---|---|---|
| 설문 | `gws forms forms get --params '{"formId":"<ID>"}'` | 읽기 |
| 응답 | `gws forms forms responses list --params '{"formId":"<ID>"}'` | 읽기 |
| 만들기 | `gws forms forms create --json '{"info":{"title":"<제목>"}}'` | 쓰기 |

## Meet (`meet`)

| 작업 | 명령 | 종류 |
|---|---|---|
| 지난 회의 | `gws meet conferenceRecords list` | 읽기 |
| 회의 공간 만들기 | `gws meet spaces create --json '{}'` (회의 링크 반환) | 쓰기 |

링크가 있는 회의 일정은 `gws calendar +insert ... --meet`이 더 간단합니다.

## Keep (`keep`) — Workspace 계정 전용, 개인 Gmail 계정은 보통 403

`gws keep notes list`, `gws keep notes get --params '{"name":"notes/<id>"}'`.

## Classroom (`classroom`)

`gws classroom courses list`, `gws classroom courses courseWork list --params '{"courseId":"<id>"}'`.

## Apps Script (`script`)

| 작업 | 명령 | 종류 |
|---|---|---|
| 프로젝트 내용 | `gws script projects getContent --params '{"scriptId":"<ID>"}'` | 읽기 |
| 로컬 파일 올리기 | `gws script +push --script <ID> [--dir ./src]` | 쓰기 — 프로젝트의 **모든** 파일을 교체 |

## Admin reports (`admin-reports`, 별칭 `reports`)

Workspace 관리자 계정 전용(감사 로그, 사용량). 개인 계정은 쓸 수 없습니다.

## 그 밖의 기능 찾기

- `gws <서비스> --help` → 리소스와 헬퍼
- `gws <서비스> <리소스> --help` → 메서드
- `gws schema <서비스>.<리소스>.<메서드>` → 파라미터와 본문 구조
