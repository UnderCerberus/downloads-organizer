$targetDir = Join-Path $env:USERPROFILE "DownloadsOrganizer"
if (-not (Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir -Force | Out-Null }

$scriptUrl = "https://raw.githubusercontent.com/UnderCerberus/downloads-organizer/main/DownloadsOrganizer.ps1"
$ps1Path = Join-Path $targetDir "DownloadsOrganizer.ps1"

Write-Host "Downloading DownloadsOrganizer.ps1..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $scriptUrl -OutFile $ps1Path

$vbsContent = @"
Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & "$targetDir\DownloadsOrganizer.ps1" & """", 0, False
"@
$vbsPath = Join-Path $targetDir "run_silent.vbs"
Set-Content -Path $vbsPath -Value $vbsContent -Encoding ASCII

$startupFolder = [System.Environment]::GetFolderPath('Startup')
$shortcutPath = Join-Path $startupFolder "DownloadsOrganizer.lnk"

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($shortcutPath)
$Shortcut.TargetPath = "wscript.exe"
$Shortcut.Arguments = """$vbsPath"""
$Shortcut.WindowStyle = 0
$Shortcut.Save()

Write-Host "Starting organizer in background..." -ForegroundColor Green
Start-Process "wscript.exe" -ArgumentList """$vbsPath"""

Write-Host "Setup complete! Downloads are now being organized automatically." -ForegroundColor Green
