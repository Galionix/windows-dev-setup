# Configure Taskbar using Boxstarter

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
. "$PSScriptRoot\..\common\logger.ps1"
. "$PSScriptRoot\..\config.ps1"

if (-not $ConfigureWindows) {
    Write-Host "Skipping Configure Windows (disabled in config)" -ForegroundColor Yellow
    exit
}

try {
    LogInfo "Applying Taskbar configuration..."

    Set-BoxstarterTaskbarOptions `
        -Combine Never `
        -DisableSearchBox

    LogSuccess "Taskbar configured: no grouping unless full, search disabled, minimal mode on second monitor"

} catch {
    Write-Host "[ERROR] Failed to apply taskbar settings" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    LogError "Taskbar config error: $($_.Exception.Message)"
}
