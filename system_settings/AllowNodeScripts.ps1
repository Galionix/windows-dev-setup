
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
. "$PSScriptRoot\..\common\logger.ps1"

. "$PSScriptRoot\..\config.ps1"

if (-not $AllowNodeScripts) {
    Write-Host "Skipping Configure AllowNodeScripts (disabled in config)" -ForegroundColor Yellow
    exit
}

Write-Host "[...] Setting execution policy for Node scripts..." -ForegroundColor Cyan
LogInfo "Setting ExecutionPolicy to RemoteSigned for Node.js scripts"

try {
    Get-ExecutionPolicy -List
    Set-ExecutionPolicy Unrestricted
    Set-ExecutionPolicy Unrestricted -Force
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
    LogSuccess "Execution policy successfully set to RemoteSigned"
} catch {
    LogError "Failed to set execution policy: $($_.Exception.Message)"
    Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
}