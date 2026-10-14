@echo off
rem Optional: runs the app on http://localhost (Windows built-in tools only, nothing to install).
rem Double-click this file, keep the window open while you work. Double-clicking index.html also works.
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\serve.ps1"
if errorlevel 1 pause
