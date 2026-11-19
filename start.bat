@echo off
setlocal
cd /d "%~dp0"
title PeakCut
if not exist ".venv\Scripts\python.exe" (
  echo Run install.bat first.
  pause
  exit /b 1
)
".venv\Scripts\python.exe" -c "import studio.server" >nul 2>nul
if errorlevel 1 (
  echo Python packages are missing. Run install.bat again.
  pause
  exit /b 1
)
start "" http://127.0.0.1:8765
".venv\Scripts\python.exe" -m studio.server
pause
