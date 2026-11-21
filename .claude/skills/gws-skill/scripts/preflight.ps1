# Check that gws can run: Node, gws, .env, and auth. Read-only; installs nothing.
# Usage: powershell -File scripts/preflight.ps1
$skillDir = Split-Path -Parent $PSScriptRoot
$ok = $true
function Show-Line($name, $pass, $detail) {
    $mark = if ($pass) { 'OK  ' } else { 'FAIL' }
    Write-Output ("[{0}] {1,-10} {2}" -f $mark, $name, $detail)
}

$node = Get-Command node -ErrorAction SilentlyContinue
Show-Line 'node' ([bool]$node) $(if ($node) { (& node --version) } else { 'install Node.js 18+ from https://nodejs.org' })
if (-not $node) { $ok = $false }

$gws = Get-Command gws -ErrorAction SilentlyContinue
$gwsVer = if ($gws) { (& gws --version 2>$null | Select-Object -First 1) } else { 'run: npm install -g @googleworkspace/cli' }
Show-Line 'gws' ([bool]$gws) $gwsVer
if (-not $gws) { $ok = $false }

$envFile = Join-Path $skillDir '.env'
$hasEnv = Test-Path $envFile
$envDetail = 'copy .env.example to .env'
if ($hasEnv) {
    $txt = [IO.File]::ReadAllText($envFile)
    $hasId = $txt -match '(?m)^GOOGLE_WORKSPACE_CLI_CLIENT_ID=\S+'
    $hasSecret = $txt -match '(?m)^GOOGLE_WORKSPACE_CLI_CLIENT_SECRET=\S+'
    $hasEnv = $hasId -and $hasSecret
    $envDetail = if ($hasEnv) { 'client id + secret set' } else { 'client id or secret is empty' }
}
Show-Line '.env' $hasEnv $envDetail

if ($gws) {
    $raw = & powershell -NoProfile -File (Join-Path $PSScriptRoot 'gws.ps1') auth status 2>$null | Out-String
    $valid = $raw -match '"token_valid":\s*true'
    $user = if ($raw -match '"user":\s*"([^"]+)"') { $Matches[1] } else { '' }
    $detail = if ($valid) { "token valid ($user)" } else { 'not logged in: run scripts/gws.ps1 auth login -s calendar,gmail,drive,sheets' }
    Show-Line 'auth' $valid $detail
    if (-not $valid) { $ok = $false }
}

if ($ok) { Write-Output 'READY'; exit 0 } else { Write-Output 'NOT READY (see references/setup-auth.md)'; exit 1 }
