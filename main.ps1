# Post-Install Script

# Software list
$softwareList = @(
  "dotnetfx",
  "KB2919355",
  "KB2919442",
  "KB2999226",
  "KB3033929",
  "KB3035131",
  "KB3118401",
  "vcredist-all",
  "7zip.install",
  "git.install",
  "7zip",
  "git",
  "nodejs-lts",
  "jdk8",
  "python",
  "vscode",
  "googlechrome",
  "intellijidea-community",
  "netbeans",
  "arduino",
  "androidstudio",
  "mysql",
  "mysql.workbench",
  "eclipse",
  "docker-desktop"
)

# Initial setup
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$pcName = $env:COMPUTERNAME
$logDir = "$PSScriptRoot/logs"
$cacheDir = "$PSScriptRoot/cache"
$logFile = "$logDir/${pcName}_$timestamp.log"

# Create log and cache directories
New-Item -ItemType Directory -Path $logDir, $cacheDir -ErrorAction SilentlyContinue | Out-Null

# Log function
function Write-Log($message) {
  $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  "$timestamp`t$message" | Tee-Object -FilePath $logFile -Append
}

# Chocolatey installation function
function Install-Chocolatey {
  if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Log "Chocolatey is not installed. Installing..."
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    refreshenv
    if (Get-Command choco -ErrorAction SilentlyContinue) {
      Write-Log "Chocolatey successfully installed."
    } else {
      Write-Log "Error installing Chocolatey. Operation aborted."
      exit 1
    }
  } else {
    Write-Log "Chocolatey is already installed."
  }
}

# Offline software installation function
function Install-SoftwareOffline($pkg) {
  if (-not (choco list --exact $pkg | Select-String "^$pkg")) {
    $localPackage = Get-ChildItem -Path "$cacheDir/$pkg.*.nupkg" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

    if ($localPackage) {
      Write-Log "Installing $pkg from local cache."
      choco install $pkg -s "$cacheDir" -y --ignore-checksums --force --params='/AllUsers' | Tee-Object -FilePath $logFile -Append
    } else {
      Write-Log "$pkg was not found in the local cache. Downloading and installing..."
      choco install $pkg -y --cacheLocation="$cacheDir" --params='/AllUsers' | Tee-Object -FilePath $logFile -Append
    }
  } else {
    Write-Log "$pkg is already installed."
  }
}

# Uninstall software function
function Uninstall-Software($pkg) {
  if (choco list --exact $pkg | Select-String "^$pkg") {
    Write-Log "Uninstalling $pkg..."
    choco uninstall $pkg -y --force | Tee-Object -FilePath $logFile -Append
  } else {
    Write-Log "$pkg is not installed."
  }
}

# Menu script
Write-Host "Select an option:" -ForegroundColor Cyan
Write-Host "1 - Install software"
Write-Host "2 - Uninstall software"
Write-Host "3 - Cancel"

$option = Read-Host "Option"

switch ($option) {
  "1" {
    Install-Chocolatey
    foreach ($software in $softwareList) {
      Install-SoftwareOffline $software
    }
  }

  "2" {
    foreach ($software in $softwareList) {
      Uninstall-Software $software
    }
  }

  "3" {
    Write-Log "Operation canceled."
    exit 0
  }

  Default {
    Write-Log "Invalid option. Operation canceled."
    exit 1
  }
}

Write-Log "Operation completed."
