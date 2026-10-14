# Optional local server for the LIGHT app - Windows built-in PowerShell only (no Node, no install).
# Serves the project folder on http://localhost:<port>/ to THIS computer only (loopback).
# No admin rights needed. Close the window (or Ctrl+C) to stop it.
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\serve.ps1 [-Port 8080] [-NoOpen]
#
# Without -Port it reuses the port saved in lab-mode.txt (written by /kickoff), else 8080.
# The port must stay the same from day to day: the browser keeps the app's data per address.
param([int]$Port = 0, [switch]$NoOpen)

$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$ModeFile = Join-Path $Root "lab-mode.txt"

if ($Port -eq 0) {
  $Port = 8080
  if (Test-Path $ModeFile) {
    $m = Select-String -Path $ModeFile -Pattern "localhost:(\d+)" | Select-Object -First 1
    if ($m) { $Port = [int]$m.Matches[0].Groups[1].Value }
  }
}
$Url = "http://localhost:$Port/"

$types = @{
  ".html" = "text/html; charset=utf-8"; ".js" = "text/javascript; charset=utf-8"
  ".css" = "text/css; charset=utf-8"; ".json" = "application/json"; ".csv" = "text/csv; charset=utf-8"
  ".txt" = "text/plain; charset=utf-8"; ".png" = "image/png"; ".jpg" = "image/jpeg"; ".jpeg" = "image/jpeg"
  ".gif" = "image/gif"; ".svg" = "image/svg+xml"; ".ico" = "image/x-icon"; ".webp" = "image/webp"
  ".mp4" = "video/mp4"; ".woff" = "font/woff"; ".woff2" = "font/woff2"; ".sqlite" = "application/x-sqlite3"
}

try {
  $listener = New-Object System.Net.Sockets.TcpListener ([System.Net.IPAddress]::Loopback, $Port)
  $listener.Start()
} catch {
  Write-Host "PORT BUSY: $Port is already used on this computer."
  Write-Host "If the app is already running, just open $Url"
  exit 2
}

try { $Host.UI.RawUI.WindowTitle = "Lab app - keep this window open" } catch {}
Write-Host "SERVING $Url"
Write-Host "Your app is running at $Url - keep this window open while you work."
if (-not $NoOpen) { Start-Process $Url }

function Send($stream, [int]$code, [string]$status, [string]$type, [byte[]]$body) {
  $head = "HTTP/1.1 $code $status`r`nContent-Type: $type`r`nContent-Length: $($body.Length)`r`nCache-Control: no-store`r`nConnection: close`r`n`r`n"
  $h = [System.Text.Encoding]::ASCII.GetBytes($head)
  $stream.Write($h, 0, $h.Length)
  if ($body.Length -gt 0) { $stream.Write($body, 0, $body.Length) }
}

while ($true) {
  $client = $listener.AcceptTcpClient()
  try {
    $client.ReceiveTimeout = 5000
    $client.SendTimeout = 10000
    $stream = $client.GetStream()
    $reader = New-Object System.IO.StreamReader ($stream, [System.Text.Encoding]::ASCII, $false, 4096, $true)
    $line = $reader.ReadLine()
    while ($true) { $h = $reader.ReadLine(); if ($h -eq $null -or $h -eq "") { break } }
    if (-not $line) { continue }

    $parts = $line.Split(" ")
    $path = [System.Uri]::UnescapeDataString(($parts[1] -split "[?#]")[0])
    if ($path -eq "/") { $path = "/index.html" }
    if ($path -eq "/favicon.ico") { Send $stream 204 "No Content" "text/plain" (New-Object byte[] 0); continue }
    $file = [System.IO.Path]::GetFullPath((Join-Path $Root $path.TrimStart("/")))

    if (-not $file.StartsWith($Root.TrimEnd("\", "/") + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase) -or -not (Test-Path $file -PathType Leaf)) {
      Send $stream 404 "Not Found" "text/plain" ([System.Text.Encoding]::UTF8.GetBytes("Not found"))
    } else {
      $ext = [System.IO.Path]::GetExtension($file).ToLower()
      $type = $types[$ext]; if (-not $type) { $type = "application/octet-stream" }
      $body = [System.IO.File]::ReadAllBytes($file)
      if ($parts[0] -eq "HEAD") { $body = New-Object byte[] 0 }
      Send $stream 200 "OK" $type $body
    }
  } catch {
    # a closed tab or a slow request must never stop the server
  } finally {
    $client.Close()
  }
}
