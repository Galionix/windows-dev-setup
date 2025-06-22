function Install-ZipExecutableWithUrl {
    <#
    .SYNOPSIS
        Скачивает ZIP-архив, распаковывает его, запускает EXE-файл с аргументами, опционально добавляет в автозагрузку и открывает ссылку.

    .DESCRIPTION
        Удобная функция для автоматической установки портативных приложений. Подходит для ситуаций, когда программа распространяется в ZIP-архиве без установщика.

    .PARAMETER Name
        Название приложения. Используется в логах, заголовках и имени ярлыка автозагрузки.

    .PARAMETER ZipUrl
        URL для загрузки архива .zip, содержащего исполняемый файл.

    .PARAMETER ZipPath
        Локальный путь, куда будет сохранён ZIP-архив.

    .PARAMETER ExtractPath
        Папка, куда будет извлечён архив.

    .PARAMETER ExecutableRelativePath
        Относительный путь до EXE-файла внутри извлечённой папки.

    .PARAMETER InfoUrl
        URL, который откроется после запуска приложения (например, страница справки или активации).

    .PARAMETER NoWait
        Если указан, не ждать завершения процесса запуска EXE-файла.

    .PARAMETER AddToStartup
        Если указан, добавить ярлык EXE-файла в автозагрузку пользователя.

    .EXAMPLE
        Install-ZipExecutableWithUrl `
            -Name "StrokesPlus" `
            -ZipUrl "https://example.com/StrokesPlus.zip" `
            -ZipPath "$PSScriptRoot\..\external\StrokesPlus.zip" `
            -ExtractPath "$PSScriptRoot\..\external\StrokesPlus" `
            -ExecutableRelativePath "StrokesPlus.exe" `
            -InfoUrl "https://example.com/info" `
            -AddToStartup `
            -NoWait

    .NOTES
        Автор: ты сам. Этот код — часть автоматизированной установки программ, пригоден для любого портативного EXE.
    #>

    param (
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$ZipUrl,

        [Parameter(Mandatory)]
        [string]$ZipPath,

        [Parameter(Mandatory)]
        [string]$ExtractPath,

        [Parameter(Mandatory)]
        [string]$ExecutableRelativePath,

        [string]$InfoUrl,

        [switch]$NoWait,

        [switch]$AddToStartup
    )

    Write-Host "=== Installing $Name ===" -ForegroundColor Cyan
    LogInfo "Beginning installation of $Name"

    try {
        if (-Not (Test-Path $ZipPath)) {
            Write-Host "Downloading archive..." -ForegroundColor Gray
            LogInfo "Downloading $Name archive from $ZipUrl"
            Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipPath
            LogSuccess "Downloaded $Name archive"
        } else {
            Write-Host "Archive already exists, skipping download." -ForegroundColor Yellow
            LogInfo "$Name archive already exists"
        }

        if (-Not (Test-Path $ExtractPath)) {
            Write-Host "Extracting archive..." -ForegroundColor Gray
            LogInfo "Extracting $Name archive"
            Expand-Archive -Path $ZipPath -DestinationPath $ExtractPath
            LogSuccess "Extracted $Name to $ExtractPath"
        } else {
            Write-Host "Already extracted, skipping extraction." -ForegroundColor Yellow
            LogInfo "$Name already extracted"
        }

        $exePath = Join-Path $ExtractPath $ExecutableRelativePath
        if (Test-Path $exePath) {
            Write-Host "Running $Name..." -ForegroundColor Gray
            LogInfo "Launching $Name executable at $exePath"

            if ($NoWait) {
                Start-Process -FilePath $exePath -ArgumentList "/S /verysilent /norestart /quiet /norestart /s /q"
            } else {
                Start-Process -FilePath $exePath -ArgumentList "/S /verysilent /norestart /quiet /norestart /s /q" -Wait
            }

            LogSuccess "$Name launched"

            if ($AddToStartup) {
                $startupFolder = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
                $shortcutPath = Join-Path $startupFolder "$Name.lnk"
                $shell = New-Object -ComObject WScript.Shell
                $shortcut = $shell.CreateShortcut($shortcutPath)
                $shortcut.TargetPath = $exePath
                $shortcut.WorkingDirectory = Split-Path $exePath
                $shortcut.Save()

                LogSuccess "$Name added to Startup: $shortcutPath"

                Write-Host "Opening Startup folder..." -ForegroundColor Gray
                Start-Process "explorer.exe" $startupFolder
            }
        } else {
            throw "Executable not found after extraction: $exePath"
        }

        if ($InfoUrl) {
            Write-Host "Opening info URL: $InfoUrl" -ForegroundColor Gray
            LogInfo "Opening info URL for $Name"
            Open-Url $InfoUrl
        }

        Write-Host "=== $Name setup finished ===" -ForegroundColor Green
    }
    catch {
        Write-Host "[ERROR] Failed to install $Name" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        LogError "$Name installation failed: $($_.Exception.Message)"
    }
}
