@echo off
:: Перезапуск от админа, если не запущен как админ
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo Running as administrator...

if not exist "%~dp0logs" mkdir "%~dp0logs"
if not exist "%~dp0external" mkdir "%~dp0external"
if not exist "%~dp0portables" mkdir "%~dp0portables"
if not exist "%~dp0temp" mkdir "%~dp0temp"
echo Setup started at %DATE% %TIME% > "%~dp0logs\install.log"
echo For configuring windows use Boxstarter (choco install boxstarter)

:: Установка Chocolatey (если надо)
powershell -ExecutionPolicy Bypass -File "%~dp0program_groups\EnsureChoco.ps1"

:: Проверка доступности choco
where choco >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [WARNING] Chocolatey was just installed, but is not yet available in this session.
    echo Please close and re-run this script manually.
    echo.
    pause
    exit /b
)

:: Main installation script
powershell -ExecutionPolicy Bypass -File "%~dp0\common\Uninstall.ps1"

echo.
echo All tasks finished. Press any key to exit...
pause >nul