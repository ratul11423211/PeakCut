@echo off
setlocal
cd /d "%~dp0"
title PeakCut - Installer
echo.
echo PeakCut setup
echo ============
where py >nul 2>nul
if errorlevel 1 (
  echo Python Launcher missing. Install Python 3.11 x64 from https://www.python.org/downloads/windows/
  echo Enable Add python.exe to PATH during installation.
  pause
  exit /b 1
)
py -3.11 --version >nul 2>nul
if errorlevel 1 (
  echo Python 3.11 missing.
  start https://www.python.org/downloads/windows/
  pause
  exit /b 1
)
if not exist ".venv\Scripts\python.exe" (
  py -3.11 -m venv .venv
  if errorlevel 1 goto failed
)
".venv\Scripts\python.exe" -m pip install --upgrade pip
if errorlevel 1 goto failed
".venv\Scripts\python.exe" -m pip install -r requirements.txt
if errorlevel 1 goto failed
where ffmpeg >nul 2>nul
if errorlevel 1 (
  where winget >nul 2>nul
  if errorlevel 1 goto ffmpeg_manual
  choice /m "Install FFmpeg using Windows Package Manager"
  if errorlevel 2 goto ffmpeg_manual
  winget install --id Gyan.FFmpeg --exact --accept-package-agreements --accept-source-agreements
  if errorlevel 1 goto ffmpeg_manual
)
echo Setup complete. Double-click start.bat to launch PeakCut.
pause
exit /b 0
:ffmpeg_manual
echo FFmpeg is required. Install it from https://ffmpeg.org/download.html
pause
exit /b 1
:failed
echo Setup failed. Fix the error above and run install.bat again.
pause
exit /b 1
