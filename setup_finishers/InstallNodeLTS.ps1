# Install Node.js LTS using NVM

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
. "$PSScriptRoot\..\common\logger.ps1"

# Find the nvm executable dynamically
$nvmPath = Get-Command nvm | Select-Object -ExpandProperty Source

if ($nvmPath) {
    try {
        LogInfo "Installing LTS version of Node.js using nvm..."
        & $nvmPath install lts
        & $nvmPath use lts
        Write-Host "[OK] LTS version of Node.js installed" -ForegroundColor Green
        LogSuccess "LTS version of Node.js installed and activated"


        # Install npx (if not included in Node.js version)
        LogInfo "Installing npx..."
        npm install -g npx yarn pnpm postman
        Write-Host "[OK] npx installed" -ForegroundColor Green
        LogSuccess "npx installed globally"
    }
    catch {
        Write-Host "[ERROR] Failed to install Node.js LTS via NVM" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        LogError "Node.js LTS installation via NVM failed: $($_.Exception.Message)"
    }
} else {
    LogError "nvm not found. Please ensure nvm is installed correctly."
}
