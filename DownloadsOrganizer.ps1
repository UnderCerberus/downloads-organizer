$Downloads = [System.IO.Path]::Combine($env:USERPROFILE, "Downloads")

# Settings
# Files modified within this many minutes are left alone (download may still be finishing).
$SettleMinutes = 10
# Installers (.exe, .msi) are NOT moved by default so a just-downloaded installer stays where the browser put it.
$OrganizeInstallers = $false
# Old-installer deletion is OFF by default. When enabled, it only deletes files that are unlocked and
# older than 14 days by BOTH CreationTime and LastWriteTime.
$EnableInstallerCleanup = $false
$InstallerMaxAgeDays = 14

$Rules = @{
    "Images"     = @(".png", ".jpg", ".jpeg", ".webp", ".gif", ".svg", ".bmp")
    "Documents"  = @(".pdf", ".docx", ".doc", ".xlsx", ".xls", ".pptx", ".txt", ".csv")
    "Archives"   = @(".zip", ".7z", ".rar", ".tar", ".gz")
    "Installers" = @(".exe", ".msi")
}

$ExcludeExtensions = @(".crdownload", ".tmp", ".download", ".part", ".partial", ".opdownload")

Function Test-FileLocked {
    param([string]$Path)
    try {
        $fs = [System.IO.File]::Open($Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::None)
        $fs.Close()
        return $false
    } catch {
        return $true
    }
}

Function Test-FileSettled {
    param([System.IO.FileInfo]$File)
    return ($File.LastWriteTime -lt (Get-Date).AddMinutes(-$SettleMinutes))
}

Function Organize-Downloads {
    Get-ChildItem -Path $Downloads -File | ForEach-Object {
        $file = $_
        $ext = $file.Extension.ToLower()

        if ($ExcludeExtensions -contains $ext) { return }

        $targetFolder = $null
        foreach ($folder in $Rules.Keys) {
            if ($Rules[$folder] -contains $ext) {
                $targetFolder = $folder
                break
            }
        }

        if (-not $targetFolder) { return }
        if ($targetFolder -eq "Installers" -and -not $OrganizeInstallers) { return }

        # Skip files that were just written or are still open by another process (download or install in progress).
        if (-not (Test-FileSettled $file)) { return }
        if (Test-FileLocked $file.FullName) { return }

        $destPath = Join-Path $Downloads $targetFolder
        if (-not (Test-Path $destPath)) {
            New-Item -ItemType Directory -Path $destPath -Force | Out-Null
        }

        $destFilePath = Join-Path $destPath $file.Name
        $counter = 1
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        while (Test-Path $destFilePath) {
            $destFilePath = Join-Path $destPath ("{0}_{1}{2}" -f $baseName, $counter, $ext)
            $counter++
        }

        try {
            Move-Item -Path $file.FullName -Destination $destFilePath -ErrorAction Stop
        } catch {}
    }

    if ($EnableInstallerCleanup) {
        $installerPath = Join-Path $Downloads "Installers"
        if (Test-Path $installerPath) {
            $limitDate = (Get-Date).AddDays(-$InstallerMaxAgeDays)
            Get-ChildItem -Path $installerPath -File | Where-Object {
                $_.LastWriteTime -lt $limitDate -and $_.CreationTime -lt $limitDate -and -not (Test-FileLocked $_.FullName)
            } | ForEach-Object {
                Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue
            }
        }
    }
}

while ($true) {
    try {
        Organize-Downloads
    } catch {}
    Start-Sleep -Seconds 10
}
