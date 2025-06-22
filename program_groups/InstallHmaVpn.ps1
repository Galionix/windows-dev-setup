# Install HMA VPN silently

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
. "$PSScriptRoot\..\common\logger.ps1"
. "$PSScriptRoot\..\common\open-url.ps1"
. "$PSScriptRoot\..\common\Install-AndLaunch.ps1"
# $installer = "$PSScriptRoot\..\external\HMA-Setup.exe"
# $downloadUrl = "https://www.hidemyass.com/en-us/download-thank-you.php?product=HMA-WIN"

# try {
#     if (-Not (Test-Path $installer)) {
#         LogInfo "Downloading HMA installer..."
#         Invoke-WebRequest -Uri $downloadUrl -OutFile $installer
#         LogSuccess "Downloaded HMA installer"
#     } else {
#         LogInfo "HMA installer already exists, skipping download"
#     }

#     LogInfo "Starting silent installation of HMA VPN"
#     Start-Process -FilePath $installer -ArgumentList "/S /verysilent /norestart /quiet /norestart /s /q" -Wait
#     Write-Host "[OK] HMA VPN installed" -ForegroundColor Green
#     LogSuccess "HMA VPN installed silently"

#     $activationUrl = "https://mail.google.com/mail/u/0/#search/hma"
#     LogInfo "Opening browser for VPN activation code retrieval"
#     Open-Url $activationUrl
# }
# catch {
#     Write-Host "[ERROR] Failed to install HMA VPN" -ForegroundColor Red
#     Write-Host $_.Exception.Message -ForegroundColor Red
#     LogError "HMA installation failed: $($_.Exception.Message)"
# }
Install-AndLaunch `
  -DownloadUrl "https://www.hidemyass.com/en-us/download-thank-you.php?product=HMA-WIN" `
  -ExecutableName "HMA-Setup.exe" `
  -AfterInstallUrl "https://mail.google.com/mail/u/0/#search/hma"

