# Run gws with the skill's .env loaded. Usage: scripts/gws.ps1 <gws args...>
# Example: powershell -File scripts/gws.ps1 calendar +agenda --today
$ErrorActionPreference = 'Stop'
$skillDir = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $skillDir '.env'

if (Test-Path $envFile) {
    foreach ($line in [IO.File]::ReadAllLines($envFile)) {
        $t = $line.Trim()
        if ($t -eq '' -or $t.StartsWith('#') -or -not $t.Contains('=')) { continue }
        $i = $t.IndexOf('=')
        $k = $t.Substring(0, $i).Trim()
        $v = $t.Substring($i + 1).Trim().Trim('"').Trim("'")
        if ($v -ne '') { [Environment]::SetEnvironmentVariable($k, $v, 'Process') }
    }
} else {
    [Console]::Error.WriteLine("gws-skill: $envFile not found. Copy .env.example to .env (see references/setup-auth.md).")
}

# gcloud is only needed for setup, but keep it reachable if installed in the default place.
$gcloudBin = Join-Path $env:LOCALAPPDATA 'google-cloud-sdk\bin'
if (Test-Path $gcloudBin) { $env:PATH = "$gcloudBin;$env:PATH" }

if (-not (Get-Command gws -ErrorAction SilentlyContinue)) {
    [Console]::Error.WriteLine("gws-skill: gws not found. Install with: npm install -g @googleworkspace/cli")
    exit 127
}

# UTF-8 so Korean text in arguments and output survives Windows PowerShell 5.1.
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$OutputEncoding = [Text.Encoding]::UTF8

& gws @args
exit $LASTEXITCODE
