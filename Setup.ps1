$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$InstallDir = Join-Path $env:LOCALAPPDATA "PeakCut"
$RepoZip = Join-Path $env:TEMP "peakcut-source.zip"
$ExtractDir = Join-Path $env:TEMP "peakcut-source"
$Branch = "feature/viral-radar-intelligence"
$ZipUrl = "https://github.com/ratul11423211/PeakCut/archive/refs/heads/$Branch.zip"

Write-Host ""
Write-Host "  PeakCut Setup" -ForegroundColor Cyan
Write-Host "  This installs PeakCut for your Windows user. Your videos and settings stay in the data folder."
Write-Host ""

# Python 3.11 is the supported install target for the Windows setup.
$Python = $null
if (Get-Command py -ErrorAction SilentlyContinue) {
    try { & py -3.11 --version *> $null; if ($LASTEXITCODE -eq 0) { $Python = "py" } } catch {}
}
if (-not $Python -and (Get-Command python -ErrorAction SilentlyContinue)) {
    try { & python --version *> $null; if ($LASTEXITCODE -eq 0) { $Python = "python" } } catch {}
}
if (-not $Python) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw "Python 3.11 was not found and winget is unavailable. Install Python 3.11, then run Setup again."
    }
    Write-Host "Installing Python 3.11..."
    winget install --id Python.Python.3.11 --exact --scope user --accept-package-agreements --accept-source-agreements
    Write-Host "Python was installed. Close this window, open PowerShell again, and run Setup once more." -ForegroundColor Yellow
    exit 0
}

# Install FFmpeg when it is not already available.
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue) -or -not (Get-Command ffprobe -ErrorAction SilentlyContinue)) {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "Installing FFmpeg..."
        winget install --id Gyan.FFmpeg --exact --scope user --accept-package-agreements --accept-source-agreements
        Write-Host "FFmpeg installation requested. If setup cannot find it, reopen PowerShell and run Setup again." -ForegroundColor Yellow
    } else {
        throw "FFmpeg is required. Install it from https://ffmpeg.org/download.html, then run Setup again."
    }
}

if (Test-Path $ExtractDir) { Remove-Item $ExtractDir -Recurse -Force }
if (Test-Path $RepoZip) { Remove-Item $RepoZip -Force }
Write-Host "Downloading PeakCut..."
Invoke-WebRequest -Uri $ZipUrl -OutFile $RepoZip
Expand-Archive -Path $RepoZip -DestinationPath $ExtractDir -Force
$Source = Get-ChildItem $ExtractDir -Directory | Select-Object -First 1
if (-not $Source -or -not (Test-Path (Join-Path $Source.FullName "studio\server.py"))) {
    throw "The downloaded PeakCut source did not look complete."
}

New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
# Overlay application files instead of deleting the install folder. This preserves data/, .env,
# storage.json, secrets/ and any other local settings during a repair or upgrade.
Get-ChildItem -LiteralPath $Source.FullName -Force | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination $InstallDir -Recurse -Force
}

$VenvPython = Join-Path $InstallDir ".venv\Scripts\python.exe"
if (-not (Test-Path $VenvPython)) {
    if ($Python -eq "py") { & py -3.11 -m venv (Join-Path $InstallDir ".venv") }
    else { & python -m venv (Join-Path $InstallDir ".venv") }
}
Write-Host "Installing PeakCut components (this can take several minutes)..."
& $VenvPython -m pip install --upgrade pip
& $VenvPython -m pip install -r (Join-Path $InstallDir "requirements.txt")
if ($LASTEXITCODE -ne 0) { throw "Python components could not be installed. Check your internet connection and run Setup again." }

$Desktop = [Environment]::GetFolderPath("Desktop")
$ShortcutPath = Join-Path $Desktop "PeakCut.lnk"
$Shell = New-Object -ComObject WScript.Shell
$Shortcut = $Shell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = Join-Path $InstallDir "Start PeakCut.bat"
$Shortcut.WorkingDirectory = $InstallDir
$Shortcut.IconLocation = "$env:SystemRoot\System32\SHELL32.dll,13"
$Shortcut.Description = "Start your local PeakCut video clipping studio"
$Shortcut.Save()

Write-Host ""
Write-Host "PeakCut is installed." -ForegroundColor Green
Write-Host "Open the PeakCut shortcut on your Desktop."
Write-Host "First start downloads the speech model (about 480 MB)."
Write-Host "Your clips, settings and AI key stay in: $InstallDir\data"
