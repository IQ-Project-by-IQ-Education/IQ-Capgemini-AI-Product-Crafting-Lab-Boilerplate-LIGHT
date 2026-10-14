# LIGHT app launcher - Windows. Decides and runs how the app is opened; saves the choice in lab-mode.txt.
# Built-in Windows tools only. Never installs anything.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\launch.ps1 <command> [server] [-Open]
#
#   auto                 first run (/kickoff): reuse lab-mode.txt, or try the servers
#                        (powershell, node, python, perl; ~4 s each), else file mode
#   restart              make sure the saved mode is running (same address)
#   file                 force file mode (trainer: /force-filebased)
#   server [name]        force localhost mode (trainer: /force-serverbased); name = powershell|node|python|perl
#   status | stop
#
# The last line printed always starts with RESULT.
param([string]$Command = "auto", [string]$Only = "", [switch]$Open)

$ErrorActionPreference = "SilentlyContinue"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$ModeFile = Join-Path $Root "lab-mode.txt"
$Tools = Join-Path $Root "tools"
$Size = (Get-Item (Join-Path (Join-Path $Root "vendor") "sql-asm.js")).Length
$IsWin = $env:OS -eq "Windows_NT"
if ($env:LAB_SERVERS) { $Order = $env:LAB_SERVERS -split " " } else { $Order = @("powershell", "node", "python", "perl") }  # LAB_SERVERS only for testing

function Get-Mode([string]$key) {
  if (Test-Path $ModeFile) {
    foreach ($l in Get-Content $ModeFile) { if ($l.StartsWith("$key=")) { return $l.Substring($key.Length + 1) } }
  }
  return ""
}
function Get-SavedPort { if ((Get-Mode "url") -match "^http://localhost:(\d+)/") { return [int]$Matches[1] }; return 0 }
function Get-FileUrl {
  $p = (Join-Path $Root "index.html") -replace "\\", "/" -replace " ", "%20"
  if ($p.StartsWith("/")) { return "file://$p" } else { return "file:///$p" }
}

# Content length of a local URL, -1 if nothing answers. Bypasses any corporate proxy.
function Probe([int]$port, [string]$path, [int]$ms) {
  try {
    $r = [System.Net.HttpWebRequest]::Create("http://localhost:$port$path")
    $r.Proxy = $null; $r.Timeout = $ms; $r.ReadWriteTimeout = $ms
    $resp = $r.GetResponse(); $len = $resp.ContentLength; $resp.Close(); return $len
  } catch [System.Net.WebException] {
    if ($_.Exception.Response) { $_.Exception.Response.Close(); return -2 }
    return -1
  } catch { return -1 }
}
function Test-Answers([int]$port) { return (Probe $port "/vendor/sql-asm.js" 2000) -eq $Size }
function Test-Taken([int]$port) { return (Probe $port "/" 1000) -ne -1 }

function Q([string]$s) { return '"' + $s + '"' }
function Get-Exe([string]$s) {
  switch ($s) {
    "powershell" {
      if ($IsWin) { $exe = "powershell.exe" } else { $exe = Join-Path $PSHOME "pwsh" }
      return @{ File = $exe; Args = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", (Q (Join-Path $Tools "serve.ps1")), "-NoOpen", "-Port") }
    }
    "node" {
      $c = Get-Command node -CommandType Application | Select-Object -First 1
      if ($c) { return @{ File = $c.Source; Args = @((Q (Join-Path $Tools "serve.js"))) } }
    }
    "python" {
      foreach ($n in @("python", "python3", "py")) {
        $c = Get-Command $n -CommandType Application | Select-Object -First 1
        # skip the Microsoft Store placeholder (it opens the Store instead of running Python)
        if ($c -and $c.Source -notlike "*\WindowsApps\*") {
          $a = @((Q (Join-Path $Tools "serve.py"))); if ($n -eq "py") { $a = @("-3") + $a }
          return @{ File = $c.Source; Args = $a }
        }
      }
    }
    "perl" {
      $c = Get-Command perl -CommandType Application | Select-Object -First 1
      if ($c) { return @{ File = $c.Source; Args = @((Q (Join-Path $Tools "serve.pl"))) } }
    }
  }
  return $null
}

# Start one server in its own minimized window and wait up to ~4 s for it to answer. Returns the pid or $null.
function Start-One([string]$s, [int]$port) {
  $e = Get-Exe $s
  if (-not $e) { Write-Host "TRIED ${s}: not available"; return $null }
  $params = @{ FilePath = $e.File; ArgumentList = ($e.Args + "$port"); PassThru = $true }
  if ($IsWin) { $params.WindowStyle = "Minimized" }
  else { $params.RedirectStandardOutput = Join-Path ([System.IO.Path]::GetTempPath()) "lab-app-server.log" }
  $proc = Start-Process @params
  if (-not $proc) { Write-Host "TRIED ${s}: could not start (blocked?)"; return $null }
  for ($i = 0; $i -lt 16; $i++) {
    if (Test-Answers $port) { return $proc.Id }
    if ($proc.HasExited) { break }
    Start-Sleep -Milliseconds 250
  }
  Stop-Process -Id $proc.Id -Force
  Write-Host "TRIED ${s}: no answer on port $port"
  return $null
}

function Write-Localhost([string]$server, [int]$port, $procId) {
  Set-Content -Path $ModeFile -Encoding ASCII -Value @("mode=localhost", "server=$server", "url=http://localhost:$port/", "pid=$procId")
}
function Write-File { Set-Content -Path $ModeFile -Encoding ASCII -Value @("mode=file", "url=$(Get-FileUrl)") }

function Stop-Servers {
  $procId = Get-Mode "pid"
  if ($procId) { Stop-Process -Id ([int]$procId) -Force }
  if ($IsWin) {
    Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like "*$Tools\serve.*" } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
  }
  Start-Sleep -Milliseconds 300
}

function Get-FreePort {
  foreach ($p in @(8080, 8081, 8082)) { if ((Test-Answers $p) -or -not (Test-Taken $p)) { return $p } }
  return 0
}

# Try the servers in order on one port. Writes lab-mode.txt on success.
function Try-Servers($list, [int]$port, [string]$known = "unknown") {
  if (Test-Answers $port) { Write-Localhost $known $port ""; return $true }
  foreach ($s in $list) {
    $procId = Start-One $s $port
    if ($procId) { Write-Localhost $s $port $procId; return $true }
  }
  return $false
}

function Ensure-Running {
  # Saved localhost mode: keep the SAME port (the browser keeps the app's data per address).
  $port = Get-SavedPort
  if (Test-Answers $port) { return $true }
  $first = Get-Mode "server"
  $list = @($first) + ($Order | Where-Object { $_ -ne $first })
  return (Try-Servers $list $port $first)
}

function Show-Result {
  if ((Get-Mode "mode") -eq "localhost") { "RESULT mode=localhost server=$(Get-Mode 'server') url=$(Get-Mode 'url')" }
  else { "RESULT mode=file url=$(Get-Mode 'url')" }
  if ($Open) { Start-Process (Get-Mode "url") }
}
function Show-Down { "RESULT error=server-down url=$(Get-Mode 'url') (no server could start on the saved port; a trainer can run /force-filebased)" }

switch ($Command) {
  "auto" {
    if (Test-Path $ModeFile) {
      if ((Get-Mode "mode") -eq "localhost" -and -not (Ensure-Running)) { Show-Down; exit 1 }
      Show-Result; exit 0
    }
    $port = Get-FreePort
    if ($port -and (Try-Servers $Order $port)) { Show-Result; exit 0 }
    Write-File
    Show-Result
  }
  "restart" {
    if (-not (Test-Path $ModeFile)) { $port = Get-FreePort; if (-not ($port -and (Try-Servers $Order $port))) { Write-File }; Show-Result; exit 0 }
    if ((Get-Mode "mode") -eq "localhost" -and -not (Ensure-Running)) { Show-Down; exit 1 }
    Show-Result
  }
  "file" {
    Stop-Servers
    Write-File
    Show-Result
  }
  "server" {
    $backup = $null; if (Test-Path $ModeFile) { $backup = Get-Content $ModeFile }
    if ($Only) { $list = @($Only) } else { $list = $Order }
    $port = Get-SavedPort
    Stop-Servers
    if (-not $port) { $port = Get-FreePort }
    if ($port -and (Try-Servers $list $port)) { Show-Result; exit 0 }
    if ($backup) { Set-Content -Path $ModeFile -Encoding ASCII -Value $backup } else { Remove-Item $ModeFile }
    if ((Get-Mode "mode") -eq "localhost") { Ensure-Running | Out-Null }
    "RESULT error=no-server tried=`"$($list -join ' ')`" (previous mode kept; see the TRIED lines above)"
    exit 1
  }
  "status" {
    if (-not (Test-Path $ModeFile)) { "RESULT mode=none (run /kickoff)"; exit 0 }
    if ((Get-Mode "mode") -eq "localhost") {
      if (Test-Answers (Get-SavedPort)) { $run = "yes" } else { $run = "no" }
      "RESULT mode=localhost server=$(Get-Mode 'server') url=$(Get-Mode 'url') running=$run"
    } else { "RESULT mode=file url=$(Get-Mode 'url')" }
  }
  "stop" { Stop-Servers; "RESULT stopped" }
  default { "RESULT error=unknown-command ($Command)"; exit 1 }
}
