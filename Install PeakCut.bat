@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Setup.ps1"
if errorlevel 1 (
  echo.
  echo Setup could not finish. Read the error above.
  pause
  exit /b 1
)
echo.
pause
