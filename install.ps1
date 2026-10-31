param(
  [ValidateSet("desktop", "web")]
  [string]$Profile = "desktop",
  [switch]$Local
)

$ErrorActionPreference = "Stop"
$Repo = "komeiji-cobalt/dsh-isaac-widget"

function Find-Dsh {
  # Prefer the CLI shipped with the running desktop app: it is the only one
  # that is allowed to manage the reserved "desktop" profile.
  $candidates = @()
  if ($env:LOCALAPPDATA) {
    $candidates += (Join-Path $env:LOCALAPPDATA "Programs\DeepSeek Harness\resources\runtime\cli\bin\dsh.cmd")
  }
  if ($env:ProgramFiles) {
    $candidates += (Join-Path $env:ProgramFiles "DeepSeek Harness\resources\runtime\cli\bin\dsh.cmd")
  }
  $pf86 = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)")
  if ($pf86) {
    $candidates += (Join-Path $pf86 "DeepSeek Harness\resources\runtime\cli\bin\dsh.cmd")
  }

  foreach ($candidate in $candidates) {
    if ($candidate -and (Test-Path -LiteralPath $candidate)) { return $candidate }
  }

  $cmd = Get-Command dsh -ErrorAction SilentlyContinue
  if ($cmd) { return $cmd.Source }
  return $null
}

$dsh = Find-Dsh
if (-not $dsh) {
  throw "dsh CLI not found. Install DeepSeek Harness first, or add its runtime\cli\bin to PATH."
}

$spec = if ($Local) { "link:$PSScriptRoot" } else { "github:$Repo" }

Write-Host ""
Write-Host "dsh-isaac-widget" -ForegroundColor Cyan
Write-Host "  dsh:     $dsh"
Write-Host "  profile: $Profile"
Write-Host "  spec:    $spec"
Write-Host ""

& $dsh plugin --profile $Profile add $spec
if ($LASTEXITCODE -ne 0) {
  throw "dsh plugin add failed (exit $LASTEXITCODE)."
}

Write-Host ""
Write-Host "Installed." -ForegroundColor Green
if ($Profile -eq "desktop") {
  Write-Host "Fully quit DeepSeek Harness (including the tray icon), then reopen it."
} else {
  Write-Host "Restart the dsh web server, then refresh the browser."
}
Write-Host "A small Isaac should appear at the bottom-right. Click him for the spider bubble + HurtGrunt."
Write-Host ""
