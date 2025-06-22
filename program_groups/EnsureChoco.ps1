[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
. "$PSScriptRoot\..\common\logger.ps1"

Write-Host "Checking Chocolatey installation..." -ForegroundColor Cyan
LogInfo "Checking Chocolatey installation"

if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "[...] Chocolatey not found. Installing..." -ForegroundColor Yellow
    LogInfo "Chocolatey not found. Installing..."

    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

        if (Get-Command choco -ErrorAction SilentlyContinue) {
            Write-Host "[OK] Chocolatey installed successfully" -ForegroundColor Green
            LogSuccess "Chocolatey successfully installed"

            $chocoBin = "$env:ALLUSERSPROFILE\chocolatey\bin"

            if (-not ($env:PATH -split ";" | Where-Object { $_ -eq $chocoBin })) {
                Write-Host "[INFO] Adding Chocolatey bin to PATH: $chocoBin" -ForegroundColor Cyan
                LogInfo "Adding Chocolatey bin to PATH: $chocoBin"
                $env:PATH += ";$chocoBin"
            } else {
                Write-Host "[INFO] Chocolatey bin path already in PATH: $chocoBin" -ForegroundColor Gray
                LogInfo "Chocolatey bin path already present in PATH: $chocoBin"
            }

        } else {
            Write-Host "[ERROR] Chocolatey installation failed" -ForegroundColor Red
            LogError "Chocolatey installation failed"
            throw "Chocolatey installation failed"
        }
    } catch {
        Write-Host "[ERROR] Chocolatey install error: $($_.Exception.Message)" -ForegroundColor Red
        LogError "Chocolatey install error: $($_.Exception.Message)"
        throw
    }
} else {
    Write-Host "[SKIP] Chocolatey is already installed" -ForegroundColor Gray
    LogInfo "Chocolatey is already installed"
}
