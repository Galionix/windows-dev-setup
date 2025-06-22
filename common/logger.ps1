# logger.ps1 — reusable logging functions
$Global:LogPath = "$PSScriptRoot\..\logs\install.log"

function LogInfo($msg) {
    $ts = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    Add-Content -Path $LogPath -Value "[$ts] [INFO] $msg"
}

function LogSuccess($msg) {
    $ts = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    Add-Content -Path $LogPath -Value "[$ts] [OK] $msg"
}

function LogError($msg) {
    $ts = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    Add-Content -Path $LogPath -Value "[$ts] [ERROR] $msg"
}
