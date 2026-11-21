#!/usr/bin/env bash
# Run gws with the skill's .env loaded. Usage: scripts/gws.sh <gws args...>
# Example: bash scripts/gws.sh calendar +agenda --today
skill_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
env_file="$skill_dir/.env"

if [ -f "$env_file" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%$'\r'}"
    case "$line" in ''|\#*) continue ;; esac
    [[ "$line" == *=* ]] || continue
    key="${line%%=*}"; val="${line#*=}"
    key="$(echo "$key" | xargs)"; val="${val#\"}"; val="${val%\"}"; val="${val#\'}"; val="${val%\'}"
    [ -n "$val" ] && export "$key=$val"
  done < "$env_file"
else
  echo "gws-skill: $env_file not found. Copy .env.example to .env (see references/setup-auth.md)." >&2
fi

# gcloud is only needed for setup; add the default Windows install location if present.
if [ -n "$LOCALAPPDATA" ]; then
  gbin="$(cygpath -u "$LOCALAPPDATA" 2>/dev/null)/google-cloud-sdk/bin"
  [ -d "$gbin" ] && export PATH="$gbin:$PATH"
fi

if ! command -v gws >/dev/null 2>&1; then
  echo "gws-skill: gws not found. Install with: npm install -g @googleworkspace/cli" >&2
  exit 127
fi

exec gws "$@"
