[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
. "$PSScriptRoot\..\common\logger.ps1"

Write-Host "=== Updating WSL for Docker ===" -ForegroundColor Cyan
LogInfo "Running 'wsl --update' to ensure WSL is up to date..."

try {
    wsl --update | ForEach-Object { Write-Host $_ }
    Write-Host "[OK] WSL update finished" -ForegroundColor Green
    LogSuccess "WSL successfully updated"
    Write-Host "[WARNING] If WSL asked for a reboot, please reboot the system before using Docker." -ForegroundColor Yellow

}
catch {
    Write-Host "[ERROR] WSL update failed" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    LogError "WSL update failed: $($_.Exception.Message)"
}
