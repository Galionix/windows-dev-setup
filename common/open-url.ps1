function Open-Url($url) {
    try {
        $chromePaths = @(
            "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
            "$env:ProgramFiles(x86)\Google\Chrome\Application\chrome.exe"
        )

        $launched = $false

        foreach ($path in $chromePaths) {
            if (Test-Path $path) {
                Start-Process -FilePath $path -ArgumentList $url -ErrorAction Stop
                LogSuccess ("Opened URL in Chrome: " + $url)
                $launched = $true
                break
            }
        }

        if (-not $launched) {
            Start-Process -FilePath $url -ErrorAction Stop
            LogSuccess ("Opened URL in default browser: " + $url)
        }
    }
    catch {
        $msg = "Failed to open URL $url. Error: " + $_.Exception.Message
        Write-Host "[ERROR] $msg" -ForegroundColor Red
        LogError $msg
    }
}
