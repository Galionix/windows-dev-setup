[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::CursorVisible = $false

. "$PSScriptRoot\common\logger.ps1"
. "$PSScriptRoot\config.ps1"


# Проверяем, запущен ли скрипт с правами администратора
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Write-Host "[ERROR] This script requires administrator privileges. Please run as Administrator." -ForegroundColor Red
    Pause
    exit
}

$steps = @(
    @{ Name = "=== SYSTEM CONFIGURATION ==="; Separator = $true },
    @{ Name = "Configure System Settings"; Path = "$PSScriptRoot\system_settings\ConfigureSystem.ps1"; Selected = $true },
    @{ Name = "Configure Taskbar"; Path = "$PSScriptRoot\system_settings\ConfigureTaskbar.ps1"; Selected = $true },
    @{ Name = "Allow Node Scripts"; Path = "$PSScriptRoot\system_settings\AllowNodeScripts.ps1"; Selected = $true }
)

$steps += @(@{
    Name = "=== CORE TOOLS SELECTION ==="
    Separator = $true
},
     @{ Name = "Install Core Tools"; Path = "$PSScriptRoot\program_groups\InstallCoreTools.ps1"; Selected = $true }
)


foreach ($tool in $Tools) {
    $steps += @{
        Name = "Install $tool"
        ToolName = $tool
        CoreTool = $true
        Selected = $true
    }
}
$steps += @(
    @{ Name = "=== PROGRAM INSTALLATION ==="; Separator = $true },
    @{ Name = "Install HMA VPN"; Path = "$PSScriptRoot\program_groups\InstallHmaVpn.ps1"; Selected = $true },
    @{ Name = "Install StrokesPlusNet"; Path = "$PSScriptRoot\program_groups\InstallStrokesPlusNet.ps1"; Selected = $true },
    @{ Name = "Install Punto Switcher"; Path = "$PSScriptRoot\program_groups\InstallPuntoSwitcher.ps1"; Selected = $true },

    @{ Name = "=== FINALIZATION ==="; Separator = $true },
    @{ Name = "Setup Git Config"; Path = "$PSScriptRoot\setup_finishers\git.ps1"; Selected = $true },
    @{ Name = "Update WSL"; Path = "$PSScriptRoot\setup_finishers\WSLUpdate.ps1"; Selected = $true },
    @{ Name = "OpenAIEnv"; Path = "$PSScriptRoot\setup_finishers\OpenAIEnv.ps1"; Selected = $false },
    @{ Name = "Install Node LTS"; Path = "$PSScriptRoot\setup_finishers\InstallNodeLTS.ps1"; Selected = $true }
)

$index = 0
$done = $false

function DrawMenu {
    Clear-Host
    Write-Host "==============================================="
    Write-Host "Select steps to execute (Space = toggle, Enter = start, Q = quit):"
    Write-Host "===============================================`n"

    for ($i = 0; $i -lt $steps.Count; $i++) {
        if ($steps[$i].Separator) {
            Write-Host ""
            Write-Host $steps[$i].Name -ForegroundColor Magenta
        }
        else {
            $prefix = if ($steps[$i].Selected) { "[X]" } else { "[ ]" }
            if ($i -eq $index) {
                Write-Host "-> $prefix $($steps[$i].Name)" -ForegroundColor Cyan
            } else {
                Write-Host "   $prefix $($steps[$i].Name)"
            }
        }
    }
}

while (-not $done) {
    DrawMenu

    $key = [Console]::ReadKey($true)

    if ($steps[$index].Separator) {
        if ($key.Key -eq 'DownArrow' -and $index -lt ($steps.Count - 1)) { $index++ }
        if ($key.Key -eq 'UpArrow' -and $index -gt 0) { $index-- }
        continue
    }

    switch ($key.Key) {
        'UpArrow'    { if ($index -gt 0) { $index-- } }
        'DownArrow'  { if ($index -lt ($steps.Count - 1)) { $index++ } }
        'Spacebar'   { $steps[$index].Selected = -not $steps[$index].Selected }
        'Enter'      { $done = $true }
        'Q'          { Write-Host "`nExit requested. Bye!"; exit }
    }
}

[Console]::CursorVisible = $true
Clear-Host

$coreToolsToInstall = $steps | Where-Object { $_.CoreTool -and $_.Selected } | ForEach-Object { $_.ToolName }
$coreToolsToInstall | ConvertTo-Json -Compress | Set-Content "$PSScriptRoot\temp\selected-tools.json"

Write-Host "==============================================="
Write-Host "Starting selected tasks..." -ForegroundColor Green
Write-Host "===============================================`n"

foreach ($step in $steps) {
    if ($step.Separator) { continue }
    if ($step.Selected) {
        Write-Host "[...] Running: $($step.Name)" -ForegroundColor Yellow
        try {
            if ($step.Path) {
            & powershell -ExecutionPolicy Bypass -File $step.Path
            }
            LogSuccess "$($step.Name) completed"
        } catch {
            LogError "$($step.Name) failed: $($_.Exception.Message)"
            Write-Host "[ERROR] $($step.Name) failed" -ForegroundColor Red
        }
    } else {
        Write-Host "[SKIP] $($step.Name)"
    }
}

Write-Host "`nSetup completed. Opening logs..." -ForegroundColor Green
Start-Process notepad "$PSScriptRoot\logs\install.log"

