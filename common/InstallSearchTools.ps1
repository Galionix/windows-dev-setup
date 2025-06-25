[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
. "$PSScriptRoot\logger.ps1"

$selectedToolsPath = "$PSScriptRoot\..\temp\selected-tools.json"

Write-Host "[INFO] Starting selected tools installation..." -ForegroundColor Cyan
LogInfo "Starting selected tools installation"

if (-not (Test-Path $selectedToolsPath)) {
    Write-Host "[ERROR] No selected tools found. Run the setup selector first." -ForegroundColor Red
    LogError "Selected tools list not found at $selectedToolsPath"
    exit 1
}

try {
    $jsonContentRaw = Get-Content $selectedToolsPath -Raw
    $parsedJson = $jsonContentRaw | ConvertFrom-Json

    if ($parsedJson.value) {
        $SelectedTools = $parsedJson.value
    } else {
        $SelectedTools = $parsedJson  # Если вдруг сохранился просто массив без обёртки
    }

    Write-Host "[INFO] Loaded selected tools:" -ForegroundColor Cyan
    foreach ($tool in $SelectedTools) {
        Write-Host " - $($tool.name) [$($tool.installer)]"
    }
}
catch {
    Write-Host "[ERROR] Failed to parse selected tools JSON" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    LogError "Failed to parse selected tools JSON: $($_.Exception.Message)"
    exit 1
}

foreach ($tool in $SelectedTools) {
    $pkg = $tool.name
    $installer = $tool.installer.ToLower()

    LogInfo "Processing: ${pkg} with ${installer}"

    switch ($installer) {
        "choco" {
            $installed = choco list --local-only --exact $pkg --limit-output 2>&1
            if ($installed -match "^$pkg\|") {
                Write-Host "[SKIP] $pkg already installed (choco)" -ForegroundColor Yellow
                LogInfo "$pkg already installed via Chocolatey"
                continue
            }

            Write-Host "[...] Installing $pkg via Chocolatey..." -ForegroundColor Cyan
            try {
                choco install $pkg -y --no-progress
                Write-Host "[OK] $pkg installed via Chocolatey" -ForegroundColor Green
                LogSuccess "$pkg installed via Chocolatey"
            }
            catch {
                Write-Host "[ERROR] Failed to install $pkg via Chocolatey" -ForegroundColor Red
                LogError "Failed to install $pkg via Chocolatey: $($_.Exception.Message)"
            }
        }

        "winget" {
            $installed = winget list --exact --source winget | Select-String "^$pkg\s"
            if ($installed) {
                Write-Host "[SKIP] $pkg already installed (winget)" -ForegroundColor Yellow
                LogInfo "$pkg already installed via Winget"
                continue
            }

            Write-Host "[...] Installing $pkg via Winget..." -ForegroundColor Cyan
            try {
                winget install --id $pkg -e -h
                Write-Host "[OK] $pkg installed via Winget" -ForegroundColor Green
                LogSuccess "$pkg installed via Winget"
            }
            catch {
                Write-Host "[ERROR] Failed to install $pkg via Winget" -ForegroundColor Red
                LogError "Failed to install $pkg via Winget: $($_.Exception.Message)"
            }
        }

        "scoop" {
            $installed = scoop list | Select-String "^$pkg\s"
            if ($installed) {
                Write-Host "[SKIP] $pkg already installed (scoop)" -ForegroundColor Yellow
                LogInfo "$pkg already installed via Scoop"
                continue
            }

            Write-Host "[...] Installing $pkg via Scoop..." -ForegroundColor Cyan
            try {
                scoop install $pkg
                Write-Host "[OK] $pkg installed via Scoop" -ForegroundColor Green
                LogSuccess "$pkg installed via Scoop"
            }
            catch {
                Write-Host "[ERROR] Failed to install $pkg via Scoop" -ForegroundColor Red
                LogError "Failed to install $pkg via Scoop: $($_.Exception.Message)"
            }
        }

        default {
            Write-Host "[ERROR] Unknown installer type for ${pkg}: ${installer}" -ForegroundColor Red
            LogError "Unknown installer type for ${pkg}: ${installer}"
        }
    }
}

Write-Host "[OK] All selected tools processed" -ForegroundColor Green
LogSuccess "Selected tools installation complete"
