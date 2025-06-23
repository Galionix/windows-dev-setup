# 🛠️ Windows Auto Setup Script

![Demonstartion](demo.gif)

A fully automated, script-based system configuration for Windows, written in PowerShell + Batch. Designed to quickly install tools, configure settings, and prepare a developer environment in minutes.

---

## 📦 Features

### 1. 🧩 Modular Structure
Each script is separated by responsibility:
- `setup.bat` — main entry point with elevation check and ordered execution
- `program_groups/` — install specific apps or groups
- `system_settings/` — configure system-level settings like taskbar or PowerToys
- `setup_finishers/` — post-install configuration like WSL update or Git identity
- `common/` — shared utilities like logging and URL launching
- `config.ps1` — central configuration file for easy customization

### 2. 🧑‍💻 Automatic Admin Elevation
Ensures the script always runs as administrator — silently relaunches itself if needed.

### 3. ☁️ Installs Chocolatey if Missing
Detects whether Chocolatey is installed. If not, installs it and asks the user to rerun the script.

# Warning: it may fail after Chocolatey installation, so you may need to run it again.

### 4. 📥 Core Dev Tools Installer
Installs essential development software using Chocolatey (configured in `config.ps1`):
- VS Code
- Git
- NVM + Node LTS
- Docker Desktop
- PowerToys
- 7-Zip
- FiraCode
- Google Chrome
- VLC, Zoom, Telegram, and more...

### 5. 🌐 Silent Installer Helpers
Includes built-in functions to:
- Download and run `.exe` or `.zip` installers silently
- Add apps to startup if needed
- Open URLs post-installation for activation or info

### 6. 💼 Optional Software Support
Supports optional tools like:
- **HMA VPN** – installs silently and opens Gmail link for code retrieval
- **StrokesPlus.net** – downloads portable version, adds to startup
- **Punto Switcher** – installs from a packed archive

### 7. 🖥️ Windows Personalization
System tweaks like:
- Configuring the taskbar layout
- Setting up PowerToys
- Setting system defaults

### 8. 🏁 Setup Finalizers
Includes post-install configuration:
- `WSL --update` for Docker support
- Setting up Git global config
- Installing Node.js LTS with NVM

### 9. ⚙️ Centralized Config File (`config.ps1`)
Everything is driven by a central config file:
```powershell
$GitUserName = "Dmitry Galaktionov"
$GitUserEmail = "galionix2@gmail.com"

$InstallStrokesPlusNet = $true
$ConfigureWindows = $true

$FinishGit = $true
$FinishDocker = $true

$Tools = @("notepadplusplus", "git", "vscode", "telegram", "7zip", "docker-desktop", ...)
## Pick your tools here https://community.chocolatey.org/packages
```
You can toggle what to install and extend tool lists with just a few variables.

# 🛠️ **Custom Installers via Functions**:

You can easily add new apps to the setup by using these helper functions:

  - `Install-AndLaunch`: For downloading and silently installing `.exe` files.
  - `Install-ZipExecutableWithUrl`: For downloading, extracting, and running

### `Install-AndLaunch`

Downloads an `.exe` installer, runs it silently, and optionally opens a web page after installation.


### `Install-ZipExecutableWithUrl`

Downloads a ZIP archive, extracts it, launches the specified `.exe` inside, and optionally adds it to startup.


## 🏁 How to Use

1. Clone this repository to your new Windows machine.
2. Run `setup.bat` as administrator.
3. Follow the logs and prompts.
4. Profit.

---

> ⚠️ This setup is tailored to the author's personal needs. You are encouraged to fork and customize it to fit your own workflow.
