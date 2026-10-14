@echo off
rem Starts the app on this computer (Windows built-in tools only, nothing to install).
rem Reuses the way /kickoff chose (localhost or file). Double-clicking index.html also works in file mode.
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\launch.ps1" restart -Open
if errorlevel 1 pause
