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
echo Setup started at %DATE% %TIME% > "%~dp0logs\install.log"
echo For installing programs use Boxstarter (choco install boxstarter)

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

:: Если всё ок — продолжаем
echo Chocolatey is available. Continuing...

echo Starting system configuration...

REM --- Запуск настройки системы ---

@REM powershell -ExecutionPolicy Bypass -File "%~dp0system_settings\ConfigureSystem.ps1"
@REM powershell -ExecutionPolicy Bypass -File "%~dp0system_settings\ConfigureTaskbar.ps1"
@REM powershell -ExecutionPolicy Bypass -File "%~dp0program_groups\InstallHmaVpn.ps1"
@REM powershell -ExecutionPolicy Bypass -File "%~dp0program_groups\InstallStrokesPlusNet.ps1"


REM --- Здесь можно вызвать другие скрипты, например:
REM powershell -ExecutionPolicy Bypass -File "%~dp0program_groups\InstallCoreTools.ps1"
REM powershell -ExecutionPolicy Bypass -File "%~dp0vscode\ConfigureVSCode.ps1"
REM powershell -ExecutionPolicy Bypass -File "%~dp0program_groups\InstallPuntoSwitcher.ps1"

echo Running Setup Finishers...
powershell -ExecutionPolicy Bypass -File "%~dp0setup_finishers\git.ps1"
powershell -ExecutionPolicy Bypass -File "%~dp0setup_finishers\WSLUpdate.ps1"
start notepad "%~dp0logs\install.log"

echo.
echo All tasks finished. Press any key to exit...
pause >nul
