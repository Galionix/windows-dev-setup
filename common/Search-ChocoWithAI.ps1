[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::CursorVisible = $false

. "$PSScriptRoot\..\config.ps1"
. "$PSScriptRoot\logger.ps1"
. "$PSScriptRoot\open-url.ps1"

# Проверка ключа
# Сначала пробуем взять ключ из системных переменных
$envKey = [Environment]::GetEnvironmentVariable("OPENAI_API_KEY", "User")


try {
    scoop bucket add extras
    scoop bucket add versions
    scoop bucket add nonportable
    Write-Host "[OK] Scoop buckets added" -ForegroundColor Green
}
catch {
    Write-Host "[WARNING] Buckets might already be added" -ForegroundColor Yellow
}

# Если не нашли — fallback на переменную из конфига
if (-not $envKey -or $envKey -eq "") {
    $envKey = $openai_api_key
}

# Если ключа всё равно нет — просим пользователя его получить
if (-not $envKey -or $envKey -eq "") {
    Write-Host "[WARNING] OpenAI API key is missing. Opening setup page..." -ForegroundColor Yellow
    Open-Url "https://platform.openai.com/api-keys"
    exit
}

# Запрос пользователю
Write-Host "What programs do you want to install? Describe in English:"
$userInput = Read-Host ">"

if (-not $userInput) {
    Write-Host "[ERROR] No input provided. Exiting." -ForegroundColor Red
    exit
}
# телеграм, влс медиа плеер, вскод, докер
# telegram, vlc media player, vscode, docker
# Запрос в OpenAI
$headers = @{
    "Authorization" = "Bearer $envKey"
    "Content-Type" = "application/json"
}

$chatBody = @{
    model = "gpt-3.5-turbo"
    messages = @(
        @{ role = "system"; content = "You are an assistant helping to extract program names from user requests. Your answer must be only a JSON array of software names, no explanations. Strictly only in english." }
        @{ role = "user"; content = $userInput }
    )
}

try {
    Write-Host "[...] Sending request to OpenAI..." -ForegroundColor Cyan
    $response = Invoke-RestMethod -Uri "https://api.openai.com/v1/chat/completions" -Method Post -Headers $headers -Body ($chatBody | ConvertTo-Json -Depth 5)
    $content = $response.choices[0].message.content.Trim()

    # Write-Host "[INFO] Raw AI response: $content" -ForegroundColor Gray

    $programs = $content | ConvertFrom-Json
    # Write-Host "[OK] AI returned programs: $($programs -join ', ')" -ForegroundColor Green
}
catch {
    Write-Host "[ERROR] Failed to process OpenAI response." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit
}

# Полный список всех найденных пакетов
$allPackages = @()

foreach ($prog in $programs) {

    ### Chocolatey поиск
    Write-Host "[...] Searching for '$prog' in Chocolatey..." -ForegroundColor Cyan
    try {
        $url = "https://community.chocolatey.org/json/JsonApi?invoke&action=GetSuggestions&SearchTerm=$prog"
        $result = Invoke-RestMethod -Uri $url -Method Get

        foreach ($pkg in $result) {
            $obj = [PSCustomObject]@{
                PackageId     = $pkg.PackageId
                DownloadCount = $pkg.DownloadCount
                Installer     = "choco"
                Selected      = $false
            }
            $allPackages += $obj
            Write-Host "[CHOCOLATEY] Found: $($obj.PackageId), Downloads: $($obj.DownloadCount)"
        }
    }
    catch { Write-Host "[ERROR] Failed to search Chocolatey" -ForegroundColor Red }

    ### Winget поиск
    Write-Host "[...] Searching for '$prog' in Winget..." -ForegroundColor Cyan
    try {
        $wingetResults = winget search --name $prog --source winget | Select-String "^\S+\s+\S+" | Where-Object { $_ -notmatch "Name\s+Id" }

        foreach ($line in $wingetResults) {
            $parts = $line -split "\s{2,}"
            $name = $parts[0].Trim()

            if ($name -and ($allPackages.PackageId -notcontains $name)) {
                $obj = [PSCustomObject]@{
                    PackageId     = $name
                    DownloadCount = 0
                    Installer     = "winget"
                    Selected      = $false
                }
                $allPackages += $obj
                Write-Host "[WINGET] Found: $($obj.PackageId)"
            }
        }
    }
    catch { Write-Host "[ERROR] Failed to search Winget" -ForegroundColor Red }

    Write-Host "[...] Searching for '$prog' in Scoop..." -ForegroundColor Cyan
try {
    $scoopResults = scoop search $prog | ForEach-Object { $_ }

    $scoopResults | ForEach-Object { Write-Host ($_ | Out-String).Trim() -ForegroundColor DarkGray }

    foreach ($item in $scoopResults) {
        if ($item.Name) {
            $obj = [PSCustomObject]@{
                PackageId     = $item.Name
                DownloadCount = 0
                Installer     = "scoop"
                Selected      = $false
            }
            $allPackages += $obj
            Write-Host "[SCOOP] Found: $($obj.PackageId)" -ForegroundColor Green
        }
    }
}
catch {
    Write-Host "[ERROR] Failed to search Scoop" -ForegroundColor Red
}

}


if (-not $allPackages.Count) {
    Write-Host "[WARNING] No packages found. Exiting." -ForegroundColor Yellow
    pause
    exit
}


# Меню выбора
$index = 0
$done = $false

function DrawMenu {
    Clear-Host
    Write-Host "Select packages to install (Space = toggle, Enter = finish, Q = quit):"
    Write-Host "==============================================================`n"

    for ($i = 0; $i -lt $allPackages.Count; $i++) {
        $prefix = if ($allPackages[$i].Selected) { "[X]" } else { "[ ]" }
        $line = "$prefix $($allPackages[$i].PackageId) [$($allPackages[$i].Installer)]"

        if ($i -eq $index) {
            Write-Host "-> $line" -ForegroundColor Cyan
        } else {
            Write-Host "   $line"
        }
    }
}

while (-not $done) {
    DrawMenu
    $key = [Console]::ReadKey($true)

    switch ($key.Key) {
        'UpArrow'    { if ($index -gt 0) { $index-- } }
        'DownArrow'  { if ($index -lt ($allPackages.Count - 1)) { $index++ } }
        'Spacebar'   { $allPackages[$index].Selected = -not $allPackages[$index].Selected }
        'Enter'      { $done = $true }
        'Q'          { Write-Host "`nExit requested. Bye!"; exit }
        Default {
            if ($key.KeyChar -eq 'q' -or $key.KeyChar -eq 'Q') {
                Write-Host "`nExit requested. Bye!"; exit
            }
        }
    }
}

[Console]::CursorVisible = $true
Clear-Host

# Вывод финального списка
$selected = $allPackages | Where-Object { $_.Selected }

Write-Host "`nSelected packages to install:" -ForegroundColor Green
foreach ($pkg in $selected) {
    Write-Host " - $($pkg.PackageId)"
}

# Сохраняем выбранные пакеты
$tempPath = "$PSScriptRoot\..\temp"
if (-not (Test-Path $tempPath)) {
    New-Item -Path $tempPath -ItemType Directory | Out-Null
}

$finalList = @()

foreach ($item in $selected) {
    $finalList += [PSCustomObject]@{
        name      = $item.PackageId
        installer = $item.Installer
    }
}

# Даже если $finalList содержит 1 элемент, он будет сериализован как массив
, $finalList | ConvertTo-Json -Depth 3 | Set-Content "$tempPath\selected-tools.json"


# Сохраняем массив объектов как JSON
# $selectedTools | ConvertTo-Json -Depth 3 -Compress | Set-Content "$tempPath\selected-tools.json"
# $selectedTools | ConvertTo-Json -Depth 3 | Set-Content "$tempPath\selected-tools.json"
Write-Host "`n[OK] Selected tools saved to temp\selected-tools.json" -ForegroundColor Green

# Запускаем установку
Write-Host "[...] Launching InstallCoreTools.ps1..." -ForegroundColor Cyan
try {
    # tempory
    & powershell -ExecutionPolicy Bypass -File "$PSScriptRoot\..\common\InstallSearchTools.ps1"
}
catch {
    Write-Host "[ERROR] Failed to launch InstallCoreTools.ps1" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

