# downloads-organizer

Automatically sorts the Windows Downloads folder by file type, with a one-line installer.

## Categories

| Folder | Extensions |
| :--- | :--- |
| Images | .png, .jpg, .jpeg, .webp, .gif, .svg, .bmp |
| Documents | .pdf, .docx, .doc, .xlsx, .xls, .pptx, .txt, .csv |
| Archives | .zip, .7z, .rar, .tar, .gz |
| Installers | .exe, .msi |

Partial downloads (.crdownload, .tmp, .download, .part, .opdownload) are left alone. Files with the same name are renamed with a numeric suffix instead of being overwritten. Installers older than 14 days are deleted from the Installers folder.

## Install (Windows, PowerShell)

```powershell
irm https://raw.githubusercontent.com/UnderCerberus/downloads-organizer/main/install.ps1 | iex
```

The installer downloads the script to `%USERPROFILE%\DownloadsOrganizer`, adds a Startup shortcut so it runs at login, and starts it in the background.

## Manual run

```powershell
powershell -ExecutionPolicy Bypass -File DownloadsOrganizer.ps1
```

## Notes

The script runs every 10 seconds and moves files out of the Downloads folder. It is untested on this repository; review the code before running it.
