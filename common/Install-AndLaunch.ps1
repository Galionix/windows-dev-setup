function Install-AndLaunch {
    <#
    .SYNOPSIS
        Загружает EXE-файл, устанавливает его в тихом режиме и при необходимости открывает ссылку.

    .DESCRIPTION
        Эта функция автоматизирует загрузку установщика, его установку с заданными аргументами,
        и (по желанию) открытие веб-страницы после установки.

    .PARAMETER DownloadUrl
        URL, по которому будет загружен установочный EXE-файл.

    .PARAMETER ExecutableName
        Название файла (например, MyAppSetup.exe), под которым будет сохранён установщик.

    .PARAMETER TargetPath
        Папка, в которую сохраняется установщик. По умолчанию — ../external от текущего скрипта.

    .PARAMETER SilentArgs
        Аргументы командной строки для тихой установки. По умолчанию: "/S /verysilent /norestart /quiet /norestart /s /q".

    .PARAMETER AfterInstallUrl
        URL, который откроется после завершения установки. Необязательный параметр.

    .EXAMPLE
        Install-AndLaunch `
          -DownloadUrl "https://example.com/myapp.exe" `
          -ExecutableName "myapp.exe" `
          -AfterInstallUrl "https://example.com/thanks"

    .NOTES
        Автор: ты сам, Димон. Этот код используется для автоматизации установки программ в твоей системе.
    #>

    param (
        [Parameter(Mandatory)]
        [string]$DownloadUrl,

        [Parameter(Mandatory)]
        [string]$ExecutableName,

        [string]$TargetPath = "$PSScriptRoot\..\external",

        [string]$SilentArgs = "/S /verysilent /norestart /quiet /norestart /s /q",

        [string]$AfterInstallUrl = $null
    )

    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    . "$PSScriptRoot\..\common\logger.ps1"
    . "$PSScriptRoot\..\common\open-url.ps1"

    try {
        Write-Host "[...] Checking installer directory" -ForegroundColor Cyan
        if (-not (Test-Path $TargetPath)) {
            New-Item -ItemType Directory -Path $TargetPath | Out-Null
            Write-Host "[OK] Created target path: $TargetPath" -ForegroundColor Green
        }

        $installer = Join-Path $TargetPath $ExecutableName

        if (-not (Test-Path $installer)) {
            Write-Host "[...] Downloading installer from $DownloadUrl" -ForegroundColor Cyan
            LogInfo "Downloading $ExecutableName..."
            Invoke-WebRequest -Uri $DownloadUrl -OutFile $installer
            Write-Host "[OK] Downloaded to $installer" -ForegroundColor Green
            LogSuccess "Downloaded $ExecutableName to $installer"
        } else {
            Write-Host "[SKIP] Installer already exists: $installer" -ForegroundColor Yellow
            LogInfo "$ExecutableName already exists, skipping download"
        }

        Write-Host "[...] Running installer silently..." -ForegroundColor Cyan
        LogInfo "Installing $ExecutableName silently..."
        Start-Process -FilePath $installer -ArgumentList $SilentArgs -Wait
        Write-Host "[OK] Installed $ExecutableName" -ForegroundColor Green
        LogSuccess "$ExecutableName installed"

        if ($AfterInstallUrl) {
            Write-Host "[...] Opening browser: $AfterInstallUrl" -ForegroundColor Cyan
            LogInfo "Opening browser to: $AfterInstallUrl"
            Open-Url $AfterInstallUrl
        }
    } catch {
        Write-Host "[ERROR] Failed to install $ExecutableName" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        LogError "$ExecutableName installation failed: $($_.Exception.Message)"
    }
}
