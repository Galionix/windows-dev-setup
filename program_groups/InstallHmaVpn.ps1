# Install HMA VPN silently
. "$PSScriptRoot\..\config.ps1"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
. "$PSScriptRoot\..\common\logger.ps1"
. "$PSScriptRoot\..\common\open-url.ps1"
. "$PSScriptRoot\..\common\Install-AndLaunch.ps1"

if (-not $InstallHmaVpn) {
    Write-Host "Skipping HMA VPN installation (disabled in config)" -ForegroundColor Yellow
    exit
}

Install-AndLaunch `
  -DownloadUrl "https://www.hidemyass.com/en-us/download-thank-you.php?product=HMA-WIN" `
  -ExecutableName "HMA-Setup.exe" `
  -AfterInstallUrl "https://mail.google.com/mail/u/0/#search/hma"

