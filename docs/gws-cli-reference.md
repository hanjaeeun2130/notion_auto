# GWS CLI Reference (verified commands only)

Only commands that were actually run and checked on this machine go here. Add a command only after checking it with `gws <command> --help` and a real run.

- Verified on: 2026-11-21
- Version: `gws 0.22.5` (npm `@googleworkspace/cli`)
- Source: https://github.com/googleworkspace/cli (not an officially supported Google product)

## 1. Environment

| Item | Value |
|---|---|
| Install | `npm install -g @googleworkspace/cli` |
| gcloud | Google Cloud CLI 594.0.0 at `%LOCALAPPDATA%\google-cloud-sdk\bin` (user PATH) |
| GCP project | `notion-auto-gws-34664` (OAuth app "gws CLI", External, Testing mode) |
| Test user | the account owner (required, or login fails with "Access blocked") |
| OAuth client | Desktop app, JSON at `C:\Users\SBS\.config\gws\client_secret.json` |
| Credentials | `C:\Users\SBS\.config\gws\credentials.enc` (AES-256-GCM, key in OS keyring) |
| Enabled APIs | Calendar, Gmail, Drive, Sheets, Docs |
| Login scopes | `calendar`, `gmail.modify`, `drive`, `spreadsheets` (+ openid, email, profile) |

Notes:
- `gws auth setup` (v0.22.5) does **not** create a project or OAuth client. It stops with "OAuth client creation requires manual setup". Create the project with `gcloud projects create`, configure the consent screen and Desktop client in Cloud Console, then run `gws auth login`.
- Unverified (Testing) apps allow about 25 scopes. Always pass `-s <services>`; do not use the full preset.
- PowerShell 5.1 needs escaped quotes in `--params` (`'{\"pageSize\": 3}'`). Git Bash takes plain JSON.
- Every command prints `Using keyring backend: keyring` to stderr first. Ignore it.

## 2. Exit codes

| Code | Meaning |
|---|---|
| 0 | Success |
| 1 | API error |
| 2 | Auth error (missing, expired, or invalid credentials) → rerun `gws auth login -s ...` |
| 3 | Validation error |
| 4 | Discovery error |
| 5 | Internal error |

## 3. Auth (check command used by gws-executor)

| Purpose | Command | Side effect |
|---|---|---|
| **CLI check (installed + authenticated)** | `gws auth status` → expect `"token_valid": true` | none |
| Login / re-login | `gws auth login -s calendar,gmail,drive,sheets` | opens OAuth URL, saves credentials |
| Log out | `gws auth logout` | deletes saved credentials |

## 4. Calendar (read-only)

| Purpose | Command |
|---|---|
| List calendars | `gws calendar calendarList list --params '{"fields":"items(id,summary,accessRole)"}'` |
| Agenda, all calendars | `gws calendar +agenda --days 30 --timezone Asia/Seoul` (also `--today`, `--tomorrow`, `--week`, `--format table`) |
| Agenda, one calendar | `gws calendar +agenda --days 30 --calendar '<name or ID>'` |
| Events in a range | `gws calendar events list --params '{"calendarId":"<ID>","timeMin":"<RFC3339>","timeMax":"<RFC3339>","singleEvents":true,"orderBy":"startTime"}'` |
| Keyword search | add `"q":"진흥원"` to the `events list` params (matches title, description, location) |

`+agenda` is documented as read-only and never modifies events.

### 진흥원 calendars (for the 회사 sync)

진흥원 schedules live in separate calendars, not in `primary`. Most event titles do not contain the word `진흥원`, so `q` search alone misses them.

| Calendar | ID | Access |
|---|---|---|
| 진흥원(한재은) | `rfusg4c7r7fl7vbds9ohuq4fdo@group.calendar.google.com` | owner |
| 진흥원(박유혁) | `qn0dgambnbe7jnrli1tvk5bq6s@group.calendar.google.com` | reader |
| 진흥원(엄태현) | `k6a6d7tkfgp2ph9uqff6sha8ss@group.calendar.google.com` | reader |
| 진흥원(서성석) | `7bs8l5i8rhmp4pg0pnur0bfum8@group.calendar.google.com` | reader |

## 5. Drive (read-only)

| Purpose | Command |
|---|---|
| List files | `gws drive files list --params '{"pageSize": 5, "fields": "files(id,name)"}'` |

## 6. Not verified yet

Gmail draft/send, Docs/Sheets/Drive create, and Calendar write commands are not verified. Do not use them until each is checked with `--help`, tested with `--dry-run`, and added here.
