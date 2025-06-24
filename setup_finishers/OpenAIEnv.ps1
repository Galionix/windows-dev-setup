[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
. "$PSScriptRoot\..\config.ps1"
. "$PSScriptRoot\..\common\logger.ps1"

Write-Host "=== Setting OpenAI API Key system environment variable ===" -ForegroundColor Cyan
LogInfo "Configuring system environment variable for OpenAI API key"

try {
    if (-not $openai_api_key -or $openai_api_key -eq "") {
        Write-Host "[WARNING] OpenAI API key not set in config.ps1, skipping..." -ForegroundColor Yellow
        LogInfo "OpenAI API key missing, nothing to configure"
        exit
    }

    Write-Host "[...] Setting OPENAI_API_KEY for current user..." -ForegroundColor Gray
    [System.Environment]::SetEnvironmentVariable("OPENAI_API_KEY", $openai_api_key, "User")

    Write-Host "[...] Setting OPENAI_API_KEY for system (requires admin)..." -ForegroundColor Gray
    [System.Environment]::SetEnvironmentVariable("OPENAI_API_KEY", $openai_api_key, "Machine")

    Write-Host "[OK] OPENAI_API_KEY environment variable set" -ForegroundColor Green
    LogSuccess "OPENAI_API_KEY environment variable successfully configured"

}
catch {
    Write-Host "[ERROR] Failed to set environment variable" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    LogError "Failed to set OPENAI_API_KEY: $($_.Exception.Message)"
}
