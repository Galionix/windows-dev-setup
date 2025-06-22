# Install Core Developer Tools
$env:chocolateyAllowEmptyChecksums = 'true'
$env:chocolateyUseWindowsCompression = 'true'
$env:chocolateyConfirmAll = 'true'
$env:chocolateyForce = 'true'

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
. "$PSScriptRoot\..\common\logger.ps1"

$packages = @(
    "notepadplusplus"
    "git"
    "nvm"
    "vscode"
    "docker-desktop"
    "googlechrome"
    "7zip"
    "firacode"
    "powertoys"
"zoom"
"vlc"
"spacesniffer"
"malwarebytes"
"telegram"

)

foreach ($pkg in $packages) {

$installed = choco list --local-only --exact $pkg --limit-output 2>&1

if ($installed -match "^$pkg\|") {
    Write-Host "[SKIP] $pkg is already installed" -ForegroundColor Yellow
    LogInfo "$pkg is already installed - skipped"
    continue
}

    Write-Host "[...] Installing $pkg..." -ForegroundColor Cyan
    LogInfo "Installing $pkg..."


    try {
        choco install $pkg -y --no-progress
        Write-Host "[OK] $pkg installed" -ForegroundColor Green
        LogSuccess "$pkg installed"
    }
catch {
    Write-Host "[ERROR] Failed to install $pkg" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    $msg = "Failed to install ${pkg}: $($_.Exception.Message)"
    LogError $msg
}


}

# Now call the external script for installing Node.js LTS
. "$PSScriptRoot\..\program_groups\InstallNodeLTS.ps1"
