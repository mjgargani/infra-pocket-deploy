# Post-Install Script

# Dependecies
$dependencyList = @(
  "dotnetfx",
  "KB2919355",
  "KB2919442",
  "KB2999226",
  "KB3033929",
  "KB3035131",
  "KB3118401",
  "vcredist-all",
  "7zip.install",
  "git.install"
)

# Software list
$softwareList = @(
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

# Create desktop shortcut function
function Set-DesktopShortcut() {
  $commonDesktop = [Environment]::GetFolderPath("CommonDesktopDirectory")
  $userDesktop = [Environment]::GetFolderPath("Desktop")
  $adminDesktops = @(
    "C:\Users\Administrador\Desktop",
    "C:\Users\Administrator\Desktop",
    "C:\Users\àdm\Desktop"
  )
  $localAppDataPrograms = "$env:LOCALAPPDATA\Programs"
  $startMenuPrograms = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"

  # Define the search paths
  $searchPaths = @(
    $localAppDataPrograms,
    $userDesktop,
    $startMenuPrograms
  ) + $adminDesktops

  # Define the exclusion list
  $exclusionList = @(
    "Accessibility",
    "Accessories",
    "Administrative Tools",
    "Maintenance",
    "StartUp",
    "System Tools",
    "Windows PowerShell",
    "Immersive Control Panel.lnk"
  )

  # Copy shortcuts to the common desktop
  foreach ($path in $searchPaths) {
    try {
      $shortcuts = Get-ChildItem -Path $path -Recurse -Filter "*.lnk" -ErrorAction SilentlyContinue
      foreach ($shortcut in $shortcuts) {
        $relativePath = $shortcut.FullName.Substring($path.Length + 1)
        if ($exclusionList -notcontains $relativePath.Split('\')[0]) {
          $shortcutPath = Join-Path $commonDesktop $shortcut.Name
          Copy-Item -Path $shortcut.FullName -Destination $shortcutPath -Force
          Write-Log "Shortcut '$($shortcut.Name)' copied to $shortcutPath."
        }
      }
    }
    catch {
      Write-Log "No shortcuts found in $path."
    }
  }
}


# Menu script
Write-Host "Select an option:" -ForegroundColor Cyan
Write-Host "1 - Install software"
Write-Host "2 - Uninstall software"
Write-Host "3 - Create common shortcuts"
Write-Host "4 - Cancel"

$option = Read-Host "Option"

switch ($option) {
  "1" {
    Install-Chocolatey
    foreach ($dependency in $dependencyList) {
      Install-SoftwareOffline $dependency
    }
    foreach ($software in $softwareList) {
      Install-SoftwareOffline $software
    }
  }

  "2" {
    Install-Chocolatey
    foreach ($dependency in $dependencyList) {
      Uninstall-Software $dependency
    }
    foreach ($software in $softwareList) {
      Uninstall-Software $software
    }
  }

  "3" {
    foreach ($software in $softwareList) {
      Set-DesktopShortcut $software 
    }
  }

  "4" {
    Write-Log "Operation canceled."
    exit 0
  }

  Default {
    Write-Log "Invalid option. Operation canceled."
    exit 1
  }
}

Write-Log "Operation completed."
