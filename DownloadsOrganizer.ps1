$Downloads = [System.IO.Path]::Combine($env:USERPROFILE, "Downloads")

$Rules = @{
    "Images"     = @(".png", ".jpg", ".jpeg", ".webp", ".gif", ".svg", ".bmp")
    "Documents"  = @(".pdf", ".docx", ".doc", ".xlsx", ".xls", ".pptx", ".txt", ".csv")
    "Archives"   = @(".zip", ".7z", ".rar", ".tar", ".gz")
    "Installers" = @(".exe", ".msi")
}

$ExcludeExtensions = @(".crdownload", ".tmp", ".download", ".part", ".opdownload")

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

        if ($targetFolder) {
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
                Move-Item -Path $file.FullName -Destination $destFilePath -Force -ErrorAction Stop
            } catch {}
        }
    }

    $installerPath = Join-Path $Downloads "Installers"
    if (Test-Path $installerPath) {
        $limitDate = (Get-Date).AddDays(-14)
        Get-ChildItem -Path $installerPath -File | Where-Object { $_.LastWriteTime -lt $limitDate } | ForEach-Object {
            Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue
        }
    }
}

while ($true) {
    Organize-Downloads
    Start-Sleep -Seconds 10
}
