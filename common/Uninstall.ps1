[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
. "$PSScriptRoot\logger.ps1"

while ($true) {
    Clear-Host
    Write-Host "`n[INFO] Gathering installed packages..." -ForegroundColor Cyan

    $installedPackages = @()

    # --- Chocolatey ---
    try {
        $chocoList = choco list | Select-String "^\S+"
        foreach ($line in $chocoList) {
            $pkg = $line.ToString().Split('|')[0].Trim()
            if ($pkg) {
                $installedPackages += [PSCustomObject]@{
                    Name      = $pkg
                    Installer = "choco"
                }
            }
        }
    }
    catch { Write-Host "[ERROR] Failed to list Chocolatey packages" -ForegroundColor Red }

    # --- Winget ---
    try {
        $wingetList = winget list --source winget | Select-String "^\S+\s+\S+" | Where-Object { $_ -notmatch "Name\s+Id" }
        foreach ($line in $wingetList) {
            $parts = $line -split "\s{2,}"
            $pkg = $parts[0].Trim()
            if ($pkg) {
                $installedPackages += [PSCustomObject]@{
                    Name      = $pkg
                    Installer = "winget"
                }
            }
        }
    }
    catch { Write-Host "[ERROR] Failed to list Winget packages" -ForegroundColor Red }

    # --- Scoop ---
    try {
        $scoopList = scoop list

        foreach ($item in $scoopList) {
            if ($item.Name) {
                $installedPackages += [PSCustomObject]@{
                    Name      = $item.Name
                    Installer = "scoop"
                }
            }
        }
    }
    catch { Write-Host "[ERROR] Failed to list Scoop packages" -ForegroundColor Red }


    if (-not $installedPackages.Count) {
        Write-Host "[INFO] No installed packages detected. Exiting..." -ForegroundColor Yellow
        break
    }

    Write-Host "`nInstalled packages:" -ForegroundColor Green
    $installedPackages | Sort-Object Name | ForEach-Object {
        Write-Host " - $($_.Name) [$($_.Installer)]"
    }

    Write-Host "`nEnter package names to uninstall (comma separated), or Q to quit:"
    $userInput = Read-Host ">"

    if ($userInput -eq "Q" -or $userInput -eq "q") {
        Write-Host "[INFO] Exit requested. Goodbye!" -ForegroundColor Yellow
        break
    }

    if (-not $userInput) {
        Write-Host "[INFO] No input provided. Returning to menu..." -ForegroundColor Yellow
        continue
    }

    $targets = $userInput -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ }

    foreach ($target in $targets) {
        # $match = $installedPackages | Where-Object { $_.Name -eq $target }

        # if (-not $match) {
        #     Write-Host "[SKIP] Package not found: $target" -ForegroundColor Yellow
        #     continue
        # }

        # switch ($match.Installer) {
            # "choco" {
                Write-Host "[...] Uninstalling $target via Chocolatey..." -ForegroundColor Cyan
                echo Y | choco uninstall $target -y
                Write-Host "Trying to uninstall with different options..." -ForegroundColor Yellow
                echo Y | choco uninstall $target -y --force --ignore-checksums -n
                Write-Host "Trying to uninstall with different options..." -ForegroundColor Yellow
                echo Y | choco uninstall $target -y --skip-autouninstaller --ignore-checksums
            # }
            # "winget" {
                Write-Host "[...] Uninstalling $target via Winget..." -ForegroundColor Cyan
                winget uninstall $target -e
            # }
            # "scoop" {
                Write-Host "[...] Uninstalling $target via Scoop..." -ForegroundColor Cyan
                scoop uninstall $target
            # }
            # default {
            #     Write-Host "[ERROR] Unknown installer for $target" -ForegroundColor Red
            # }
        # }
    }
    Write-Host "`n[INFO] Refreshing package list..." -ForegroundColor Cyan
    pause
    Start-Sleep -Seconds 2
}
