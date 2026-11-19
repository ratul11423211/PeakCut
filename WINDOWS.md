# PeakCut Windows quick installer

## Install
1. Download this repository ZIP and extract it.
2. Right-click `Setup.ps1` and choose **Run with PowerShell**. If Windows blocks the script, open PowerShell in this folder and run:
   `powershell -ExecutionPolicy Bypass -File .\Setup.ps1`
3. Setup installs the app under `%LOCALAPPDATA%\PeakCut`, prepares its Python environment and creates a **PeakCut** desktop shortcut.
4. Double-click the shortcut. PeakCut opens in your browser at http://127.0.0.1:8765.

The first run downloads the speech recognition model (about 480 MB). Then open **Settings → AI**, choose a provider and model, paste your own API key and press **Save and test**. An AI key is optional; without one, PeakCut can still use its loudness-based fallback.

## Local browser app
The browser version and Windows launcher are the same local PeakCut installation. The server listens on your own computer; no public hosting is required. Keep the command window open while using PeakCut.

## Data and privacy
Videos, generated clips, creator workspaces, settings and AI credentials are stored locally in the PeakCut data folder. Do not share that folder. Back it up before reinstalling or moving computers.

## Troubleshooting
- If Setup just installed Python or FFmpeg, close PowerShell, open it again and run Setup a second time.
- If port 8765 is busy, close the other app using it before launching PeakCut.
- If video tools are missing, install FFmpeg with `winget install Gyan.FFmpeg`, then restart PeakCut.
- For manual startup, open PowerShell in the install folder and run `.venv\Scripts\python.exe -m studio.server`.
