# Configure Explorer and search options using Boxstarter

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
. "$PSScriptRoot\..\common\logger.ps1"
. "$PSScriptRoot\..\config.ps1"

if (-not $ConfigureWindows) {
    Write-Host "Skipping Configure Windows (disabled in config)" -ForegroundColor Yellow
    exit
}

try {
    LogInfo "Applying Windows Explorer visibility settings..."

    Set-WindowsExplorerOptions `
        -EnableShowFileExtensions `
        -EnableShowHiddenFilesFoldersDrives `
        -EnableShowProtectedOSFiles

    LogSuccess "Enabled: show file extensions, hidden files, protected OS files"

    Disable-GameBarTips
    LogSuccess "Disabled GameBar tips for games"

} catch {
    Write-Host "[ERROR] Failed to apply Boxstarter settings" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    LogError "Boxstarter config error: $($_.Exception.Message)"
}
