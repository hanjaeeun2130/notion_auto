# 설치와 인증

사전 점검(preflight) 결과가 READY가 아니거나, 명령이 종료 코드 2로 끝나거나, 사용자가 새 PC에 gws를 설정하려 할 때 이 문서를 봅니다.

## 목차
1. 설치
2. `.env`의 인증 정보
3. OAuth 클라이언트 만들기 (최초 1회)
4. 로그인
5. 권한(scope)·서비스 추가
6. 문제 해결

## 1. 설치

| 필요한 것 | 명령 | 확인 |
|---|---|---|
| Node.js 18+ | https://nodejs.org (또는 `winget install OpenJS.NodeJS.LTS`) | `node --version` |
| gws | `npm install -g @googleworkspace/cli` | `gws --version` |
| gcloud (프로젝트 생성·API 활성화에만 필요) | Windows: `https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-<버전>-windows-x86_64.zip`을 받습니다(최신 `<버전>`은 `https://dl.google.com/dl/cloudsdk/channels/rapid/components-2.json`에 있음). `%LOCALAPPDATA%`에 압축을 풀고 `google-cloud-sdk\install.bat --quiet`를 실행한 뒤, `%LOCALAPPDATA%\google-cloud-sdk\bin`을 사용자 PATH에 추가합니다(설치 프로그램이 못 하는 경우가 많음) | `gcloud --version` |

버전 없는 zip 주소는 404가 나므로 버전이 들어간 이름을 쓰세요.

## 2. `.env`의 인증 정보

`scripts/gws.ps1` / `scripts/gws.sh`는 gws를 실행하기 전에 skill 폴더 `.env`의 `KEY=value` 줄을 모두 환경변수로 등록합니다. gws가 읽는 변수는 다음과 같습니다.

| 변수 | 용도 |
|---|---|
| `GOOGLE_WORKSPACE_CLI_CLIENT_ID` | OAuth 데스크톱 클라이언트 ID (`auth login`과 토큰 갱신에 사용) |
| `GOOGLE_WORKSPACE_CLI_CLIENT_SECRET` | OAuth 클라이언트 secret |
| `GOOGLE_WORKSPACE_PROJECT_ID` | 할당량·결제에 쓰는 GCP 프로젝트 |
| `GOOGLE_WORKSPACE_CLI_CONFIG_DIR` | 선택: 설정 폴더 (기본 `~/.config/gws`) |
| `GOOGLE_WORKSPACE_CLI_CREDENTIALS_FILE` | 선택: 브라우저 없는 환경·서비스 계정용 인증 JSON |
| `GOOGLE_WORKSPACE_CLI_TOKEN` | 선택: 액세스 토큰 직접 지정 (최우선) |
| `GOOGLE_WORKSPACE_CLI_KEYRING_BACKEND` | 선택: OS 키링이 없는 PC에서는 `file` |
| `GWS_TIMEZONE` | skill 기본 시간대 (gws는 읽지 않음) |

실행 스크립트를 거치면 `gws auth status`에 `"credential_source": "environment_variables"`로 나옵니다. 로그인 토큰 자체는 `.env`가 아니라 `~/.config/gws/credentials.enc`에 암호화되어 저장됩니다(키는 OS 키링).

`.env`에는 secret이 들어 있습니다. git에서 제외되어 있으니 값을 출력하지 말고, skill을 다른 사람에게 줄 때는 빼세요(받는 사람은 `.env.example`로 직접 만듭니다).

## 3. OAuth 클라이언트 만들기 (최초 1회)

`gws auth setup`(0.22.5)은 gcloud와 프로젝트까지만 확인하고 "OAuth client creation requires manual setup"에서 멈춥니다. 대신 아래 순서로 진행합니다.

1. `gcloud auth login`(사용자 로그인) 후 프로젝트 생성: `gcloud projects create <id> --name=<이름>`, 이어서 `gcloud config set project <id>`.
2. API 활성화: `gcloud services enable calendar-json.googleapis.com gmail.googleapis.com drive.googleapis.com sheets.googleapis.com docs.googleapis.com --project <id>` (필요하면 `slides`, `tasks`, `people`, `chat`, `forms`, `keep`, `meet`, `classroom`, `script` 추가).
3. 동의 화면: `https://console.cloud.google.com/auth/overview/create?project=<id>` → 앱 이름, 지원 이메일, 대상 **외부**, 연락처 이메일을 입력하고, 사용자가 Google API 서비스 사용자 데이터 정책에 동의한 뒤 만들기를 누릅니다.
4. 테스트 사용자: `https://console.cloud.google.com/auth/audience?project=<id>` → 사용자 추가 → 사용자 Google 계정 → 저장. 이걸 빠뜨리면 로그인이 "Access blocked"로 실패합니다.
5. 클라이언트: `https://console.cloud.google.com/auth/clients/create?project=<id>` → 애플리케이션 유형 **데스크톱 앱** → 만들기 → 클라이언트 ID와 secret을 `.env`에 넣습니다(또는 JSON 다운로드).

정책 동의와 로그인은 사용자 본인이 할 일이므로 그 단계는 사용자에게 요청하세요.

## 4. 로그인

```
bash scripts/gws.sh auth login -s calendar,gmail,drive,sheets
```

`https://accounts.google.com/o/oauth2/auth?...redirect_uri=http://localhost:<포트>` 주소를 출력하고 기다립니다. 사용자가 주소를 열어 계정을 고르고, 확인되지 않은 앱 경고에서 고급 → "<앱>(으)로 이동(안전하지 않음)"을 누르고(본인이 만든 테스트 앱이라 정상), 권한을 허용하면 CLI가 `"status": "success"`를 출력합니다. 브라우저 작업이 끝날 때까지 멈춰 있으므로 백그라운드로 실행하거나 사용자가 직접 실행하게 하세요(`! bash <skill>/scripts/gws.sh auth login -s ...`).

확인: `bash scripts/gws.sh auth status` → `"token_valid": true`.

## 5. 권한(scope)·서비스 추가

테스트 모드 앱은 scope가 약 25개로 제한되므로 필요한 서비스만 적으세요. 로그인을 다시 하면 scope 목록이 통째로 바뀌므로 기존 것도 포함합니다.

```
bash scripts/gws.sh auth login -s calendar,gmail,drive,sheets,docs,tasks
```

먼저 프로젝트에서 해당 API를 켜야 합니다(3.2). 안 켜면 403 `accessNotConfigured`로 실패합니다.

## 6. 문제 해결

| 증상 | 해결 |
|---|---|
| 종료 코드 2, `token_valid: false` | `auth login` 다시 실행 |
| "Access blocked: app has not completed verification" | 계정을 테스트 사용자로 추가 (3.4) |
| 403 `accessNotConfigured` | API 활성화 (오류의 `enable_url` 열기), 약 10초 대기 |
| 403 권한 부족 | 서비스를 추가해 다시 로그인 (5) |
| PowerShell에서 종료 코드 3 "key must be a string" | JSON 따옴표를 `\"`로 이스케이프, 실행 스크립트를 `&`로 호출, 또는 Bash 사용 |
| `gws: command not found` | `npm install -g @googleworkspace/cli`, `%APPDATA%\npm`이 PATH에 있는지 확인 |
| `gws auth setup`: "No GCP project configured" | `gcloud config set project <id>` 또는 `--project <id>` |
| 브라우저 없는 PC | 브라우저가 있는 PC에서 `gws auth export --unmasked > creds.json` 후 `GOOGLE_WORKSPACE_CLI_CREDENTIALS_FILE` 지정 |
| 로그아웃 / 초기화 | `gws auth logout` (저장된 인증 정보 삭제 — 먼저 확인받기) |
