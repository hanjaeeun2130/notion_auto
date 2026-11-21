#!/usr/bin/env bash
# Check that gws can run: Node, gws, .env, and auth. Read-only; installs nothing.
# Usage: bash scripts/preflight.sh
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skill_dir="$(dirname "$here")"
ok=1
line() { printf '[%s] %-10s %s\n' "$1" "$2" "$3"; }

if command -v node >/dev/null 2>&1; then line "OK  " node "$(node --version)"; else line FAIL node "install Node.js 18+"; ok=0; fi
if command -v gws >/dev/null 2>&1; then line "OK  " gws "$(gws --version 2>/dev/null | head -1)"; else line FAIL gws "run: npm install -g @googleworkspace/cli"; ok=0; fi

env_file="$skill_dir/.env"
if [ -f "$env_file" ] && grep -qE '^GOOGLE_WORKSPACE_CLI_CLIENT_ID=\S+' "$env_file" && grep -qE '^GOOGLE_WORKSPACE_CLI_CLIENT_SECRET=\S+' "$env_file"; then
  line "OK  " .env "client id + secret set"
else
  line FAIL .env "copy .env.example to .env and fill it in"
fi

if command -v gws >/dev/null 2>&1; then
  raw="$(bash "$here/gws.sh" auth status 2>/dev/null)"
  if echo "$raw" | grep -qE '"token_valid":\s*true'; then
    user="$(echo "$raw" | sed -n 's/.*"user": *"\([^"]*\)".*/\1/p' | head -1)"
    line "OK  " auth "token valid ($user)"
  else
    line FAIL auth "not logged in: run scripts/gws.sh auth login -s calendar,gmail,drive,sheets"; ok=0
  fi
fi

if [ "$ok" = 1 ]; then echo READY; exit 0; else echo "NOT READY (see references/setup-auth.md)"; exit 1; fi
