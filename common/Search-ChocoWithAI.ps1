[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::CursorVisible = $false

. "$PSScriptRoot\..\config.ps1"
. "$PSScriptRoot\logger.ps1"
. "$PSScriptRoot\open-url.ps1"

# Проверка ключа
if (-not $openai_api_key -or $openai_api_key -eq "") {
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
    "Authorization" = "Bearer $openai_api_key"
    "Content-Type" = "application/json"
}

$chatBody = @{
    model = "gpt-3.5-turbo"
    messages = @(
        @{ role = "system"; content = "You are an assistant helping to extract program names from user requests. Your answer must be only a JSON array of software names, no explanations. Strictly only in english. Convert program names to smaller ones, vlc media player to vlc" }
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

# Поиск в Chocolatey телеграм, влс медиа плеер, вскод, докер
$allPackages = @()

foreach ($prog in $programs) {
    Write-Host "[...] Searching for '$prog' in Chocolatey..." -ForegroundColor Cyan
    try {
        $url = "https://community.chocolatey.org/json/JsonApi?invoke&action=GetSuggestions&SearchTerm=$prog"
        $result = Invoke-RestMethod -Uri $url -Method Get

        if ($result.Count -gt 0) {
            foreach ($pkg in $result) {
                $allPackages += [PSCustomObject]@{
                    PackageId     = $pkg.PackageId
                    DownloadCount = $pkg.DownloadCount
                    Selected      = $false
                }
            }
        } else {
            Write-Host "No results found for $prog" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "[ERROR] Failed to search for $prog" -ForegroundColor Red
    }
}

if (-not $allPackages.Count) {
    Write-Host "[WARNING] No packages found. Exiting." -ForegroundColor Yellow
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
        $line = "$prefix $($allPackages[$i].PackageId) [$($allPackages[$i].DownloadCount) downloads]"

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

$selectedTools = $selected | ForEach-Object { $_.PackageId }
$selectedTools | ConvertTo-Json -Compress | Set-Content "$tempPath\selected-tools.json"

Write-Host "`n[OK] Selected tools saved to temp\selected-tools.json" -ForegroundColor Green


# Запускаем установку
Write-Host "[...] Launching InstallCoreTools.ps1..." -ForegroundColor Cyan
try {
    & powershell -ExecutionPolicy Bypass -File "$PSScriptRoot\..\program_groups\InstallCoreTools.ps1" -Strict
}
catch {
    Write-Host "[ERROR] Failed to launch InstallCoreTools.ps1" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

