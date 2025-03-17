# Post-Install Script

# Dependecies
$dependencyList = @(
  @{ Name = "dotnetfx"; Params = @($null) },
  @{ Name = "KB2919355"; Params = @($null) },
  @{ Name = "KB2919442"; Params = @($null) },
  @{ Name = "KB2999226"; Params = @($null) },
  @{ Name = "KB3033929"; Params = @($null) },
  @{ Name = "KB3035131"; Params = @($null) },
  @{ Name = "KB3118401"; Params = @($null) },
  @{ Name = "vcredist-all"; Params = @($null) },
  @{ Name = "7zip.install"; Params = @($null) },
  @{ Name = "git.install"; Params = @($null) }
)

# Software list
$softwareList = @(
  @{ Name = "7zip"; Params = @($null) },
  @{ Name = "git"; Params = @($null) },
  @{ Name = "nodejs-lts"; Params = @($null) },
  @{ Name = "jdk8"; Params = @($null) },
  @{ Name = "python"; Params = @($null) },
  @{ Name = "vscode"; Params = @($null) },
  @{ Name = "googlechrome"; Params = @($null) },
  @{ Name = "intellijidea-community"; Params = @($null) },
  @{ Name = "netbeans"; Params = @($null) },
  @{ Name = "arduino"; Params = @($null) },
  @{ Name = "androidstudio"; Params = @($null) },
  @{ Name = "mysql"; Params = @($null) },
  @{ Name = "mysql.workbench"; Params = @($null) },
  @{ Name = "eclipse"; Params = @($null) },
  @{ Name = "docker-desktop"; Params = @($null) }
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
function Install-SoftwareOffline($pkg, $params) {
  $paramsString = $params -join " "
  if (-not (choco list --exact $pkg | Select-String "^$pkg")) {
    $localPackage = Get-ChildItem -Path "$cacheDir/$pkg.*.nupkg" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

    if ($localPackage) {
      Write-Log "Installing $pkg from local cache."
      choco install $pkg -s "$cacheDir" -y --ignore-checksums --force $paramsString | Tee-Object -FilePath $logFile -Append
    } else {
      Write-Log "$pkg was not found in the local cache. Downloading and installing..."
      choco install $pkg -c="$cacheDir" -y --ignore-checksums --force $paramsString | Tee-Object -FilePath $logFile -Append
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

# Clean up unwanted shortcuts function
function Remove-Shortcuts() {
  $commonDesktop = [Environment]::GetFolderPath("CommonDesktopDirectory")
  $cleanupList = @(
    "7-Zip Help.lnk",
    "Git Release Notes.lnk",
    "Install Additional Tools for Node.js.lnk",
    "Python 3.13 Module Docs (64-bit).lnk",
    "Uninstall Node.js.lnk",
    "WSL Settings.lnk"
  )

  foreach ($shortcut in $cleanupList) {
    $shortcutPath = Join-Path $commonDesktop $shortcut
    if (Test-Path $shortcutPath) {
      Remove-Item $shortcutPath -Force
      Write-Log "Removed unwanted shortcut '$shortcutPath'."
    }
  }
}

# Post-Install configuration function
function Set-PostConfig {
  Write-Log "[INFO] Post-Install Configuration"

  # Arduino IDE portable mode
  $arduinoPath = "C:\Users\Administrador\AppData\Local\Programs\Arduino IDE"
  $portablePath = "$arduinoPath\portable"
  if (Test-Path $arduinoPath -and -not (Test-Path $portablePath)) {
      New-Item -ItemType Directory -Path $portablePath -Force | Out-Null
      Write-Log "[OK] Portable mode activated in $portablePath"
  } else {
      Write-Log "[INFO] Portable mode already activated"
  }

  # ENV VARS for Android SDK
  $androidSDKPath = "C:\Android\sdk"
  $androidConfigPath = "C:\Common\AndroidConfig"
  
  [System.Environment]::SetEnvironmentVariable("ANDROID_HOME", $androidSDKPath, [System.EnvironmentVariableTarget]::Machine)
  [System.Environment]::SetEnvironmentVariable("ANDROID_USER_HOME", $androidConfigPath, [System.EnvironmentVariableTarget]::Machine)
  [System.Environment]::SetEnvironmentVariable("GRADLE_USER_HOME", "$androidConfigPath\.gradle", [System.EnvironmentVariableTarget]::Machine)
  
  Write-Log "[OK] Android Studio ENV VARS configurated"
  
  # Verify ENV VARS
  $envVars = @("ANDROID_HOME", "ANDROID_USER_HOME", "GRADLE_USER_HOME")
  foreach ($var in $envVars) {
      $value = [System.Environment]::GetEnvironmentVariable($var, "Machine")
      Write-Log "[CHECK] $var = $value"
  }
  
  Write-Log "[INFO] Post-Install Configuration completed"
}


# Menu script
while ($option -ne "4") {
  Clear-Host
  Write-Host "mjgargani's Post-Install Script" -ForegroundColor Green
  Write-Host "---------------------------------" -ForegroundColor Green

  Write-Host "Select an option:" -ForegroundColor Cyan
  Write-Host "1 - Install software"
  Write-Host "2 - Uninstall software"
  Write-Host "3 - Create common shortcuts"
  Write-Host "4 - Cancel"
  Write-Host "---------------------------------" -ForegroundColor Green

  $option = Read-Host "Option"

  switch ($option) {
    "1" {
      Install-Chocolatey
      foreach ($dependency in $dependencyList) {
        Install-SoftwareOffline $dependency.Name $dependency.Params
      }
      foreach ($software in $softwareList) {
        Install-SoftwareOffline $software.Name $software.Params
      }
      Set-PostConfig
    }

    "2" {
      Install-Chocolatey
      foreach ($dependency in $dependencyList) {
        Uninstall-Software $dependency.Name
      }
      foreach ($software in $softwareList) {
        Uninstall-Software $software.Name
      }
    }

    "3" {
      foreach ($software in $softwareList) {
        Set-DesktopShortcut $software 
      }
      Remove-Shortcuts
    }

    "4" {
      Write-Log "Operation canceled."
      Start-Sleep -Seconds 1
    }

    Default {
      Write-Log "Invalid option. Operation canceled."
      Start-Sleep -Seconds 1
    }
  }
}

Write-Log "Operation completed."  
Start-Sleep -Seconds 1
exit 0
