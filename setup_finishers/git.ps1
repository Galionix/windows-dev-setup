[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
. "$PSScriptRoot\..\config.ps1"
. "$PSScriptRoot\..\common\logger.ps1"
. "$PSScriptRoot\..\config.ps1"

if (-not $FinishGit) {
    Write-Host "Skipping Configure Git (disabled in config)" -ForegroundColor Yellow
    exit
}

Write-Host "=== Configuring Git ===" -ForegroundColor Cyan
LogInfo "Configuring Git global user.name and user.email..."

try {
    Write-Host "Setting Git user.name to '$GitUserName'" -ForegroundColor Gray
    git config --global user.name "$GitUserName"

    Write-Host "Setting Git user.email to '$GitUserEmail'" -ForegroundColor Gray
    git config --global user.email "$GitUserEmail"

    Write-Host "[OK] Git global config set" -ForegroundColor Green
    LogSuccess "Git global user.name and user.email configured"

    Write-Host "Verifying Git configuration..." -ForegroundColor Gray
    git config --global user.name | ForEach-Object { Write-Host "user.name: $_" -ForegroundColor Yellow }
    git config --global user.email | ForEach-Object { Write-Host "user.email: $_" -ForegroundColor Yellow }

}
catch {
    Write-Host "[ERROR] Failed to set Git config" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    LogError "Failed to set Git config: $($_.Exception.Message)"
}
