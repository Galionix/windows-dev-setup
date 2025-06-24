[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
. "$PSScriptRoot\..\common\logger.ps1"

Write-Host "=== Checking Package Managers Installation ===" -ForegroundColor Cyan
LogInfo "Checking Chocolatey and Scoop installation..."

# Состояние установки
$allOk = $true

# --- Chocolatey ---
Write-Host "[...] Checking Chocolatey..." -ForegroundColor Cyan
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "[INSTALL] Chocolatey not found. Installing..." -ForegroundColor Yellow
    LogInfo "Chocolatey not found. Installing..."

    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

        if (Get-Command choco -ErrorAction SilentlyContinue) {
            Write-Host "[OK] Chocolatey installed successfully" -ForegroundColor Green
            LogSuccess "Chocolatey installed"

            $chocoBin = "$env:ALLUSERSPROFILE\chocolatey\bin"
            if (-not ($env:PATH -split ";" | Where-Object { $_ -eq $chocoBin })) {
                $env:PATH += ";$chocoBin"
                Write-Host "[INFO] Added Chocolatey to PATH" -ForegroundColor Gray
            }
        } else {
            Write-Host "[ERROR] Chocolatey installation failed" -ForegroundColor Red
            LogError "Chocolatey installation failed"
            $allOk = $false
        }
    }
    catch {
        Write-Host "[ERROR] Chocolatey install error: $($_.Exception.Message)" -ForegroundColor Red
        LogError "Chocolatey install error: $($_.Exception.Message)"
        $allOk = $false
    }
} else {
    Write-Host "[SKIP] Chocolatey already installed" -ForegroundColor Gray
}

# --- Scoop ---
Write-Host "[...] Checking Scoop..." -ForegroundColor Cyan
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "[INSTALL] Scoop not found. Installing..." -ForegroundColor Yellow
    LogInfo "Scoop not found. Installing..."

    try {
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        irm get.scoop.sh | iex

        if (Get-Command scoop -ErrorAction SilentlyContinue) {
            Write-Host "[OK] Scoop installed successfully" -ForegroundColor Green
            LogSuccess "Scoop installed"
        } else {
            Write-Host "[ERROR] Scoop installation failed" -ForegroundColor Red
            LogError "Scoop installation failed"
            $allOk = $false
        }
    }
    catch {
        Write-Host "[ERROR] Scoop install error: $($_.Exception.Message)" -ForegroundColor Red
        LogError "Scoop installation error: $($_.Exception.Message)"
        $allOk = $false
    }
} else {
    Write-Host "[SKIP] Scoop already installed" -ForegroundColor Gray
}

# --- Финальная проверка ---
if (-not $allOk) {
    Write-Host "[FATAL] One or more package managers failed to install. Exiting..." -ForegroundColor Red
    LogError "At least one package manager missing. Setup halted."
    exit 1
}

Write-Host "[OK] All package managers ready" -ForegroundColor Green
LogSuccess "Chocolatey and Scoop available"
