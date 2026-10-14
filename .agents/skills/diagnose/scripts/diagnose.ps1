# LIGHT lab readiness check - Windows. Needs nothing installed (built-in Windows PowerShell 5.1).
# Usage, from the project folder:
#   powershell -NoProfile -ExecutionPolicy Bypass -File .agents\skills\diagnose\scripts\diagnose.ps1
# Optional: -Open edge|chrome   opens index.html in that browser at the end.
param([string]$Open = "")

$ErrorActionPreference = "SilentlyContinue"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\..")).Path
$ExpectedSize = 1355169
$ExpectedHash = "82344159A161E30E1C012587A59567ADC02F537CD5F376270EFF88C564EED0FD"
$script:Fails = 0
$script:Warns = 0

function Report($status, $check, $detail) {
  if ($status -eq "FAIL") { $script:Fails++ }
  if ($status -eq "WARN") { $script:Warns++ }
  "{0,-5} {1,-28} {2}" -f $status, $check, $detail
}

"LIGHT LAB DIAGNOSTIC - WINDOWS"
"Date/time : $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
"Computer  : $env:COMPUTERNAME / $env:USERNAME"
"Windows   : $((Get-CimInstance Win32_OperatingSystem).Caption) $([Environment]::OSVersion.Version)"
"Folder    : $Root"
""

# 1. Browsers
$browsers = @{
  edge   = @("${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe", "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe", "$env:LOCALAPPDATA\Microsoft\Edge\Application\msedge.exe")
  chrome = @("$env:ProgramFiles\Google\Chrome\Application\chrome.exe", "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe", "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe")
}
$found = @{}
foreach ($name in @("edge", "chrome")) {
  foreach ($p in $browsers[$name]) {
    if ($p -and (Test-Path $p)) { $found[$name] = $p; break }
  }
}
if ($found.Count -eq 0) {
  Report "FAIL" "Browser (Edge or Chrome)" "neither Microsoft Edge nor Google Chrome found"
} else {
  foreach ($name in $found.Keys) {
    $v = (Get-Item $found[$name]).VersionInfo.ProductVersion
    Report "PASS" "Browser: $name" "$v  ($($found[$name]))"
  }
}

# 2. Where the folder lives
$drive = $null
try { $drive = New-Object System.IO.DriveInfo ([System.IO.Path]::GetPathRoot($Root)) } catch {}
$oneDrive = @($env:OneDrive, $env:OneDriveCommercial, $env:OneDriveConsumer) | Where-Object { $_ }
$underOneDrive = ($Root -match "OneDrive") -or ($oneDrive | Where-Object { $Root.StartsWith($_, "OrdinalIgnoreCase") })
if ($Root -match "\\AppData\\Local\\Temp\\" -and $Root -match "\.zip") {
  Report "FAIL" "Unzipped on local disk" "running from inside the zip (temp folder) - right-click the zip > Extract All first"
} elseif ($Root.StartsWith("\\") -or ($drive -and $drive.DriveType -eq "Network")) {
  Report "FAIL" "Unzipped on local disk" "folder is on a network drive - extract to a local folder, e.g. C:\Lab"
} elseif ($underOneDrive) {
  Report "WARN" "Unzipped on local disk" "folder is under OneDrive - works, but syncing can lock files; prefer C:\Lab or Downloads outside OneDrive"
} else {
  Report "PASS" "Unzipped on local disk" "$($drive.Name) ($($drive.DriveType))"
}

# 3. Boilerplate files
$required = @("index.html", "styles.css", "js\config.js", "js\schema.js", "js\db.js", "js\router.js", "js\app.js", "vendor\sql-asm.js", "AGENTS.md", "GUARDRAILS.md")
$missing = $required | Where-Object { -not (Test-Path (Join-Path $Root $_)) }
if ($missing) { Report "FAIL" "Boilerplate files" "missing: $($missing -join ', ')" }
else { Report "PASS" "Boilerplate files" "all $($required.Count) present" }

# 4. vendor/sql-asm.js intact
$sqlFile = Join-Path $Root "vendor\sql-asm.js"
if (Test-Path $sqlFile) {
  $size = (Get-Item $sqlFile).Length
  $hash = (Get-FileHash $sqlFile -Algorithm SHA256).Hash
  if ($hash -eq $ExpectedHash) {
    Report "PASS" "vendor/sql-asm.js intact" "$size bytes, checksum OK"
  } elseif ($size -gt 1300000 -and $size -lt 1400000) {
    Report "WARN" "vendor/sql-asm.js intact" "$size bytes (~1.35 MB) but checksum differs - re-extract the zip if the app stays on Loading"
  } else {
    Report "FAIL" "vendor/sql-asm.js intact" "$size bytes, expected ~$ExpectedSize - file truncated or replaced (antivirus?), re-extract the zip"
  }
} else {
  Report "FAIL" "vendor/sql-asm.js intact" "file missing (antivirus may have quarantined it)"
}

# 5. Browser policies that would break the app
$policyRoots = @(
  @{ name = "edge";   keys = @("HKLM:\SOFTWARE\Policies\Microsoft\Edge", "HKCU:\SOFTWARE\Policies\Microsoft\Edge") },
  @{ name = "chrome"; keys = @("HKLM:\SOFTWARE\Policies\Google\Chrome", "HKCU:\SOFTWARE\Policies\Google\Chrome") }
)
foreach ($b in $policyRoots) {
  $problems = @()
  foreach ($k in $b.keys) {
    $p = Get-ItemProperty $k
    if (-not $p) { continue }
    if ($p.DefaultCookiesSetting -eq 2) { $problems += "DefaultCookiesSetting=2 (site storage blocked)" }
    if ($p.DefaultJavaScriptSetting -eq 2) { $problems += "DefaultJavaScriptSetting=2 (JavaScript blocked)" }
    if ($p.DownloadRestrictions -eq 3) { $problems += "DownloadRestrictions=3 (Export cannot download)" }
    if ($p.AllowFileSelectionDialogs -eq 0) { $problems += "AllowFileSelectionDialogs=0 (Import cannot pick a file)" }
    foreach ($list in @("CookiesBlockedForUrls", "JavaScriptBlockedForUrls", "URLBlocklist")) {
      $vals = (Get-ItemProperty "$k\$list").PSObject.Properties | Where-Object { $_.Name -match "^\d+$" } | ForEach-Object { $_.Value }
      $hit = $vals | Where-Object { $_ -match "^file:" -or $_ -eq "*" }
      if ($hit) { $problems += "$list contains '$($hit -join ', ')'" }
    }
  }
  if (-not $found.ContainsKey($b.name)) { continue }
  if ($problems) { Report "WARN" "Policies: $($b.name)" ($problems -join "; ") }
  else { Report "PASS" "Policies: $($b.name)" "no policy blocking storage, JavaScript, downloads or file:// found" }
}

# 6. Optionally open the app
$url = "file:///" + ((Join-Path $Root "index.html") -replace "\\", "/")
if ($Open -and $found.ContainsKey($Open)) {
  Start-Process -FilePath $found[$Open] -ArgumentList "`"$url`""
  "INFO  Opened in $Open          $url"
}

""
"SUMMARY: $script:Fails FAIL, $script:Warns WARN"
"App link: $url"
"DIAGNOSE SCRIPT DONE"
