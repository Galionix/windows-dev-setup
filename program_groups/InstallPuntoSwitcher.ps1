# Install Punto Switcher silently from archive

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
. "$PSScriptRoot\..\common\logger.ps1"

$punto7zPath = "$PSScriptRoot\..\external\Punto.Switcher.v4.5.0.583.7z"
$extractDir = "$PSScriptRoot\..\external\Punto.Switcher.v4.5.0.583"
$exePath = Join-Path $extractDir "Punto.Switcher.v4.5.0.583\Punto.Switcher.v4.5.0.583.exe"

try {
    if (-Not (Test-Path $exePath)) {
        LogInfo "Extracting Punto Switcher archive..."
        & 7z x $punto7zPath -o"$extractDir" -y | Out-Null
        LogSuccess "Archive extracted"
    } else {
        LogInfo "Punto Switcher already extracted, skipping extraction"
    }

    if (Test-Path $exePath) {
        LogInfo "Starting Punto Switcher silent installation..."
        Start-Process -FilePath $exePath -ArgumentList "/S /I" -Wait
        Write-Host "[OK] Punto Switcher installed" -ForegroundColor Green
        LogSuccess "Punto Switcher installed silently"
    } else {
        throw "Executable not found after extraction"
    }
}
catch {
    Write-Host "[ERROR] Failed to install Punto Switcher" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    LogError "Punto Switcher installation failed: $($_.Exception.Message)"
}
