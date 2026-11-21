# GWS CLI 레퍼런스 (확인된 명령만)

이 PC에서 실제로 실행해 확인한 명령만 기록합니다. 명령은 `gws <command> --help`와 실제 실행으로 확인한 뒤에만 추가합니다.

- 확인일: 2026-11-21
- 버전: `gws 0.22.5` (npm `@googleworkspace/cli`)
- 출처: https://github.com/googleworkspace/cli (Google 공식 지원 제품 아님)

## 1. 환경

| 항목 | 값 |
|---|---|
| 설치 | `npm install -g @googleworkspace/cli` |
| gcloud | Google Cloud CLI 594.0.0, `%LOCALAPPDATA%\google-cloud-sdk\bin` (사용자 PATH) |
| GCP 프로젝트 | `notion-auto-gws-34664` (OAuth 앱 "gws CLI", 외부, 테스트 모드) |
| 테스트 사용자 | 계정 소유자 (필수, 없으면 "Access blocked"로 로그인 실패) |
| OAuth 클라이언트 | 데스크톱 앱, JSON 위치 `C:\Users\SBS\.config\gws\client_secret.json` |
| 인증 정보 | `C:\Users\SBS\.config\gws\credentials.enc` (AES-256-GCM, 키는 OS 키링) |
| 활성화된 API | Calendar, Gmail, Drive, Sheets, Docs |
| 로그인 scope | `calendar`, `gmail.modify`, `drive`, `spreadsheets` (+ openid, email, profile) |

참고:
- `gws auth setup`(v0.22.5)은 프로젝트나 OAuth 클라이언트를 **만들지 않습니다**. "OAuth client creation requires manual setup" 메시지와 함께 멈춥니다. `gcloud projects create`로 프로젝트를 만들고, Cloud Console에서 동의 화면과 데스크톱 클라이언트를 설정한 뒤 `gws auth login`을 실행하세요.
- 미확인(테스트) 앱은 scope가 약 25개로 제한됩니다. 항상 `-s <서비스>`를 지정하고, 전체 preset은 쓰지 마세요.
- PowerShell 5.1에서는 `--params`의 따옴표를 이스케이프해야 합니다(`'{\"pageSize\": 3}'`). Git Bash는 일반 JSON을 그대로 받습니다.
- 모든 명령이 먼저 stderr에 `Using keyring backend: keyring`을 출력합니다. 무시하면 됩니다.

## 2. 종료 코드

| 코드 | 의미 |
|---|---|
| 0 | 성공 |
| 1 | API 오류 |
| 2 | 인증 오류 (인증 정보 없음, 만료, 무효) → `gws auth login -s ...` 다시 실행 |
| 3 | 검증 오류 |
| 4 | Discovery 오류 |
| 5 | 내부 오류 |

## 3. 인증 (gws-executor가 쓰는 확인 명령)

| 목적 | 명령 | 부작용 |
|---|---|---|
| **CLI 확인 (설치 + 인증)** | `gws auth status` → `"token_valid": true` 확인 | 없음 |
| 로그인 / 재로그인 | `gws auth login -s calendar,gmail,drive,sheets` | OAuth URL 열림, 인증 정보 저장 |
| 로그아웃 | `gws auth logout` | 저장된 인증 정보 삭제 |

## 4. Calendar (읽기 전용)

| 목적 | 명령 |
|---|---|
| 캘린더 목록 | `gws calendar calendarList list --params '{"fields":"items(id,summary,accessRole)"}'` |
| 전체 캘린더 일정 | `gws calendar +agenda --days 30 --timezone Asia/Seoul` (`--today`, `--tomorrow`, `--week`, `--format table`도 가능) |
| 특정 캘린더 일정 | `gws calendar +agenda --days 30 --calendar '<이름 또는 ID>'` |
| 기간 내 이벤트 | `gws calendar events list --params '{"calendarId":"<ID>","timeMin":"<RFC3339>","timeMax":"<RFC3339>","singleEvents":true,"orderBy":"startTime"}'` |
| 키워드 검색 | `events list` 파라미터에 `"q":"진흥원"` 추가 (제목, 설명, 장소에서 검색) |

`+agenda`는 읽기 전용이며 이벤트를 수정하지 않는다고 문서에 나와 있습니다.

### 진흥원 캘린더 (회사 동기화용)

진흥원 일정은 `primary`가 아니라 별도 캘린더에 있습니다. 일정 제목 대부분에 `진흥원`이라는 단어가 없어서 `q` 검색만으로는 찾을 수 없습니다.

| 캘린더 | ID | 권한 |
|---|---|---|
| 진흥원(한재은) | `rfusg4c7r7fl7vbds9ohuq4fdo@group.calendar.google.com` | 소유자 |
| 진흥원(박유혁) | `qn0dgambnbe7jnrli1tvk5bq6s@group.calendar.google.com` | 읽기 |
| 진흥원(엄태현) | `k6a6d7tkfgp2ph9uqff6sha8ss@group.calendar.google.com` | 읽기 |
| 진흥원(서성석) | `7bs8l5i8rhmp4pg0pnur0bfum8@group.calendar.google.com` | 읽기 |

## 5. Drive (읽기 전용)

| 목적 | 명령 |
|---|---|
| 파일 목록 | `gws drive files list --params '{"pageSize": 5, "fields": "files(id,name)"}'` |

## 6. 아직 확인 안 됨

Gmail 초안/발송, Docs/Sheets/Drive 생성, Calendar 쓰기 명령은 아직 확인하지 않았습니다. 각각 `--help`로 확인하고 `--dry-run`으로 테스트한 뒤 여기에 추가하기 전까지는 쓰지 마세요.
