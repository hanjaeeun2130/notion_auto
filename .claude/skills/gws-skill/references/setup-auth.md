# Setup and authentication

Use this when preflight is not READY, a command exits 2, or the user wants to set gws up on a new machine.

## Contents
1. Install
2. Credentials in `.env`
3. Create the OAuth client (first time only)
4. Log in
5. Add scopes / services
6. Troubleshooting

## 1. Install

| Need | Command | Check |
|---|---|---|
| Node.js 18+ | https://nodejs.org (or `winget install OpenJS.NodeJS.LTS`) | `node --version` |
| gws | `npm install -g @googleworkspace/cli` | `gws --version` |
| gcloud (only to create a project / enable APIs) | Windows: download `https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-<ver>-windows-x86_64.zip` (latest `<ver>` is in `https://dl.google.com/dl/cloudsdk/channels/rapid/components-2.json`), unzip to `%LOCALAPPDATA%`, run `google-cloud-sdk\install.bat --quiet`, then add `%LOCALAPPDATA%\google-cloud-sdk\bin` to the user PATH (the installer often cannot) | `gcloud --version` |

The unversioned zip URL returns 404; use the versioned name.

## 2. Credentials in `.env`

`scripts/gws.ps1` / `scripts/gws.sh` export every `KEY=value` line of the skill's `.env` before calling gws. gws reads these variables:

| Variable | Purpose |
|---|---|
| `GOOGLE_WORKSPACE_CLI_CLIENT_ID` | OAuth Desktop client ID (used by `auth login` and token refresh) |
| `GOOGLE_WORKSPACE_CLI_CLIENT_SECRET` | OAuth client secret |
| `GOOGLE_WORKSPACE_PROJECT_ID` | GCP project for quota/billing |
| `GOOGLE_WORKSPACE_CLI_CONFIG_DIR` | optional: config dir (default `~/.config/gws`) |
| `GOOGLE_WORKSPACE_CLI_CREDENTIALS_FILE` | optional: credentials JSON for headless/service account |
| `GOOGLE_WORKSPACE_CLI_TOKEN` | optional: raw access token (highest priority) |
| `GOOGLE_WORKSPACE_CLI_KEYRING_BACKEND` | optional: `file` on machines without an OS keyring |
| `GWS_TIMEZONE` | skill default timezone (not read by gws) |

With the wrapper, `gws auth status` shows `"credential_source": "environment_variables"`. The login token itself is stored encrypted in `~/.config/gws/credentials.enc` (key in the OS keyring), not in `.env`.

`.env` holds a secret. It is git-ignored; never print its values, and leave it out when copying the skill to someone else (they create their own from `.env.example`).

## 3. Create the OAuth client (first time only)

`gws auth setup` (0.22.5) checks gcloud and the project but stops with "OAuth client creation requires manual setup". Do these steps instead:

1. `gcloud auth login` (user signs in) and create a project: `gcloud projects create <id> --name=<name>` then `gcloud config set project <id>`.
2. Enable APIs: `gcloud services enable calendar-json.googleapis.com gmail.googleapis.com drive.googleapis.com sheets.googleapis.com docs.googleapis.com --project <id>` (add `slides`, `tasks`, `people`, `chat`, `forms`, `keep`, `meet`, `classroom`, `script` as needed).
3. Consent screen: `https://console.cloud.google.com/auth/overview/create?project=<id>` → app name, support email, Audience **External**, contact email, then the user accepts the Google API Services User Data Policy and clicks Create.
4. Test user: `https://console.cloud.google.com/auth/audience?project=<id>` → Add users → the user's Google account → Save. Without this, login fails with "Access blocked".
5. Client: `https://console.cloud.google.com/auth/clients/create?project=<id>` → Application type **Desktop app** → Create → copy the Client ID and secret into `.env` (or download the JSON).

Accepting the policy and signing in are the user's own actions; ask them to do those steps.

## 4. Log in

```
bash scripts/gws.sh auth login -s calendar,gmail,drive,sheets
```

It prints an `https://accounts.google.com/o/oauth2/auth?...redirect_uri=http://localhost:<port>` URL and waits. The user opens it, picks the account, clicks Advanced → "Go to <app> (unsafe)" on the unverified-app warning (expected for your own Testing app), allows the scopes, and the CLI prints `"status": "success"`. Run it in the background or let the user run it (`! bash <skill>/scripts/gws.sh auth login -s ...`) because it blocks until the browser finishes.

Check: `bash scripts/gws.sh auth status` → `"token_valid": true`.

## 5. Add scopes / services

Testing-mode apps allow about 25 scopes, so list only the services you need. Re-running login replaces the scope set, so include the existing ones:

```
bash scripts/gws.sh auth login -s calendar,gmail,drive,sheets,docs,tasks
```

Enable the matching API in the project first (step 3.2), or calls fail with 403 `accessNotConfigured`.

## 6. Troubleshooting

| Symptom | Fix |
|---|---|
| exit 2, `token_valid: false` | re-run `auth login` |
| "Access blocked: app has not completed verification" | add the account as a Test user (3.4) |
| 403 `accessNotConfigured` | enable the API (open `enable_url` from the error), wait ~10 s |
| 403 insufficient scopes | re-login with the service added (5) |
| exit 3 "key must be a string" in PowerShell | escape JSON quotes `\"`, call the wrapper with `&`, or use Bash |
| `gws: command not found` | `npm install -g @googleworkspace/cli`; make sure `%APPDATA%\npm` is on PATH |
| `gws auth setup`: "No GCP project configured" | `gcloud config set project <id>` or `--project <id>` |
| Headless machine | `gws auth export --unmasked > creds.json` on a machine with a browser, then set `GOOGLE_WORKSPACE_CLI_CREDENTIALS_FILE` |
| Log out / reset | `gws auth logout` (deletes saved credentials — confirm first) |
