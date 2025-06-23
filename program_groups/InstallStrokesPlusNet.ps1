. "$PSScriptRoot\..\common\logger.ps1"
. "$PSScriptRoot\..\common\open-url.ps1"
. "$PSScriptRoot\..\common\Install-ZipExecutableWithUrl.ps1"

Install-ZipExecutableWithUrl `
  -Name "StrokesPlus.net" `
  -ZipUrl "https://github.com/ozhegov-d/StrokesPlus.net_archive/raw/refs/heads/main/StrokesPlus.net/StrokesPlus.net_Portable_0.5.7.9.zip" `
  -ZipPath "$PSScriptRoot\..\portables\StrokesPlus.zip" `
  -ExtractPath "$PSScriptRoot\..\portables\StrokesPlus" `
  -ExecutableRelativePath "StrokesPlus.net.exe" `
  -InfoUrl "https://github.com/ozhegov-d/StrokesPlus.net_archive/tree/main" `
  -NoWait `
  -AddToStartup
