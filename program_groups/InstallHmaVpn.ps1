# Install HMA VPN silently

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
. "$PSScriptRoot\..\common\logger.ps1"
. "$PSScriptRoot\..\common\open-url.ps1"
. "$PSScriptRoot\..\common\Install-AndLaunch.ps1"


Install-AndLaunch `
  -DownloadUrl "https://www.hidemyass.com/en-us/download-thank-you.php?product=HMA-WIN" `
  -ExecutableName "HMA-Setup.exe" `
  -AfterInstallUrl "https://mail.google.com/mail/u/0/#search/hma"

