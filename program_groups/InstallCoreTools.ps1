param (
    [switch]$Strict
)
. "$PSScriptRoot\..\config.ps1"

$env:chocolateyAllowEmptyChecksums = 'true'
$env:chocolateyUseWindowsCompression = 'true'
$env:chocolateyConfirmAll = 'true'
$env:chocolateyForce = 'true'

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
. "$PSScriptRoot\..\common\logger.ps1"

$selectedToolsPath = "$PSScriptRoot\..\temp\selected-tools.json"

Write-Host "[INFO] Starting Core Tools installation..." -ForegroundColor Cyan
LogInfo "Starting Core Tools installation"

if (-not (Test-Path $selectedToolsPath)) {
    Write-Host "[ERROR] No selected tools found. Run the setup selector first." -ForegroundColor Red
    LogError "Selected tools list not found at $selectedToolsPath"
    exit 1
}

try {
    $jsonContentRaw = Get-Content $selectedToolsPath -Raw
    $SelectedTools = $jsonContentRaw | ConvertFrom-Json

    LogInfo "Loaded selected tools: $($SelectedTools -join ', ')"
    Write-Host "[INFO] Loaded selected tools: $($SelectedTools -join ', ')" -ForegroundColor Cyan
}
catch {
    Write-Host "[ERROR] Failed to parse selected tools JSON" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    LogError "Failed to parse selected tools JSON: $($_.Exception.Message)"
    exit 1
}

# Определяем список для установки
if ($Strict) {
    $toolsToInstall = $SelectedTools
    Write-Host "[INFO] Strict mode enabled - installing only selected tools" -ForegroundColor Yellow
    LogInfo "Strict mode enabled - installing: $($toolsToInstall -join ', ')"
} else {
    $toolsToInstall = $Tools | Where-Object { $_ -in $SelectedTools }
    Write-Host "[INFO] Normal mode - filtering selected tools against known tools list" -ForegroundColor Yellow
    LogInfo "Normal mode - filtered tools: $($toolsToInstall -join ', ')"
}

# Установка
foreach ($pkg in $toolsToInstall) {
    LogInfo "Evaluating tool: $pkg"

    $installed = choco list --local-only --exact $pkg --limit-output 2>&1
    LogInfo "Chocolatey local lookup result for ${pkg}: $installed"

    if ($installed -match "^$pkg\|") {
        Write-Host "[SKIP] $pkg is already installed" -ForegroundColor Yellow
        LogInfo "$pkg already installed - skipping installation"
        continue
    }

    Write-Host "[...] Installing $pkg..." -ForegroundColor Cyan
    LogInfo "Installing $pkg..."

    try {
        choco install $pkg -y --no-progress
        Write-Host "[OK] $pkg installed" -ForegroundColor Green
        LogSuccess "$pkg successfully installed"
    }
    catch {
        Write-Host "[ERROR] Failed to install $pkg" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        LogError "Failed to install ${pkg}: $($_.Exception.Message)"
    }
}

Write-Host "[OK] Core tools installation complete" -ForegroundColor Green
LogSuccess "Core developer tools installation completed"
