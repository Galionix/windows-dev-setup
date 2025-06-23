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

# Проверяем наличие JSON
if (-not (Test-Path $selectedToolsPath)) {
    Write-Host "[ERROR] No selected tools found. Run the setup selector first." -ForegroundColor Red
    LogError "Selected tools list not found at $selectedToolsPath"
    exit 1
}

# Чтение выбранных тулов
try {
    $jsonContentRaw = Get-Content $selectedToolsPath -Raw
    LogInfo "Raw JSON content read from file: $jsonContentRaw"

    $SelectedTools = $jsonContentRaw | ConvertFrom-Json
    LogInfo "Parsed selected tools: $($SelectedTools -join ', ')"
    Write-Host "[INFO] Loaded selected tools: $($SelectedTools -join ', ')" -ForegroundColor Cyan
}
catch {
    Write-Host "[ERROR] Failed to parse selected tools JSON" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    LogError "Failed to parse selected tools JSON: $($_.Exception.Message)"
    exit 1
}

# Итерация по базовому списку тулов из конфиг файла
foreach ($pkg in $Tools) {
    LogInfo "Evaluating tool: $pkg"

    if ($pkg -notin $SelectedTools) {
        Write-Host "[SKIP] $pkg is not selected for installation"
        LogInfo "$pkg skipped - not in selected tools list"
        continue
    }

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
