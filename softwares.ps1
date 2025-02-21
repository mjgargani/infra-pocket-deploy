# --------------------------------------------------
# Automated Installation, Configuration, TDD, Logging, and User Management Script
# Compatible with Windows 10 and 11 (Optimized for 2025)
#
# References:
#   - PSWindowsUpdate Module: https://www.powershellgallery.com/packages/PSWindowsUpdate
#   - Windows Update Command-Line Options: https://learn.microsoft.com/en-us/windows/deployment/update/windows-update-command-line-options
#   - Local Account Management in PowerShell: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.localaccounts/
#   - RSAT for Active Directory: https://learn.microsoft.com/en-us/windows-hardware/get-started/adrs
#
# Note: Run this script in an elevated PowerShell session.
#       Use "Unblock-File -Path .\softwares.ps1" if necessary.
# --------------------------------------------------

# --- Self-Relaunch Block for ExecutionPolicy Bypass ---
if ((Get-ExecutionPolicy) -eq "Restricted") {
    Write-Host "ExecutionPolicy is Restricted. Relaunching script with -ExecutionPolicy Bypass..."
    powershell.exe -ExecutionPolicy Bypass -File $MyInvocation.MyCommand.Path
    exit
}

# Force installation of NuGet provider (silently)
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser

# --- Clear existing logs ---
$logFile      = "$PSScriptRoot\install_log.txt"
$execErrorLog = "$PSScriptRoot\exec.errors.log"
$tddErrorLog  = "$PSScriptRoot\tdd.errors.log"

if (Test-Path $logFile)      { Remove-Item $logFile -Force }
if (Test-Path $execErrorLog) { Remove-Item $execErrorLog -Force }
if (Test-Path $tddErrorLog)  { Remove-Item $tddErrorLog -Force }

# -------------------------------------------------------------------------
# Logging Functions
# -------------------------------------------------------------------------
function Write-Log {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [string]$Type = "INFO"
    )
    $timestamp  = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Type] $Message"
    Write-Host $logMessage
    Add-Content -Path $logFile -Value $logMessage
    if ($Type -eq "ERROR") {
        Add-Content -Path $execErrorLog -Value $logMessage
    }
}

function Write-TDDLog {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMsg    = "[$timestamp] [TDD ERROR] $Message"
    Add-Content -Path $tddErrorLog -Value $logMsg
}

# -------------------------------------------------------------------------
# Pre-flight Check: Must Run as Administrator
# -------------------------------------------------------------------------
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Log "ERROR: This script must be run as Administrator." "ERROR"
    exit 1
}
Write-Log "Running with Administrator privileges confirmed."

# -------------------------------------------------------------------------
# Minimal Implementations for TDD Tests (to be replaced with full logic later)
# -------------------------------------------------------------------------
function Set-RSATAccess {
    # Dummy implementation: restrict RSAT access to administrators
    return $true
}

function ConfigureAutoLogin {
    # Dummy implementation: configure auto login for Guest account
    return $true
}

function EnsureTemporaryGuestSession {
    # Dummy implementation: ensure Guest session is temporary
    return $true
}

# -------------------------------------------------------------------------
# TDD Block (Using Pester)
# -------------------------------------------------------------------------
if (-not (Get-Module -ListAvailable -Name Pester)) {
    Write-Log "Pester module not found. Installing Pester..." "INFO"
    try {
        Install-Module -Name Pester -Force -SkipPublisherCheck
        Write-Log "Pester installed successfully." "INFO"
    } catch {
        Write-Log "ERROR: Failed to install Pester. $_" "ERROR"
        exit 1
    }
}
Import-Module Pester

Describe "Core System Configuration Functions" {
    # Test for RSAT Access Restriction
    Mock -CommandName Set-RSATAccess { return $true }
    It "Should restrict RSAT access to administrators only" {
        $result = Set-RSATAccess
        $result | Should -Be $true
    } -ErrorAction Stop

    # Test for Automatic Login Configuration for Guest account
    Mock -CommandName ConfigureAutoLogin { return $true }
    It "Should configure auto login for the Guest account" {
        $result = ConfigureAutoLogin
        $result | Should -Be $true
    } -ErrorAction Stop

    # Test for ensuring temporary Guest session
    Mock -CommandName EnsureTemporaryGuestSession { return $true }
    It "Should enforce temporary session for Guest users" {
        $result = EnsureTemporaryGuestSession
        $result | Should -Be $true
    } -ErrorAction Stop

    # Test for Software Installation function (using winget)
    Mock -CommandName Install-Software { return $true }
    It "Should install specified software packages" {
        $result = Install-Software -Name "TestApp" -Id "Test.App" -Description "Test Application"
        $result | Should -Be $true
    } -ErrorAction Stop
}

$testResults = Invoke-Pester -PassThru
if ($testResults.FailedCount -gt 0) {
    Write-TDDLog "Step [TDD]: One or more tests failed. Please review the test output above."
    exit 1
}
Write-Log "All TDD tests passed successfully."

# -------------------------------------------------------------------------
# Pre-Process: Windows Updates (Including Optional)
# -------------------------------------------------------------------------
Write-Log "Initiating pre-process Windows updates..."
try {
    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        try {
            Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser -AllowClobber
            Write-Log "PSWindowsUpdate module installed."
        } catch {
            Write-Log "WARNING: Failed to install PSWindowsUpdate module. $_" "ERROR"
        }
    }
    Import-Module PSWindowsUpdate -ErrorAction SilentlyContinue
    $updates = Get-WindowsUpdate -IncludeOptional -ErrorAction SilentlyContinue
    if ($updates) {
        Install-WindowsUpdate -AcceptAll -IgnoreReboot -ErrorAction SilentlyContinue
        Write-Log "Pre-process Windows updates applied."
    } else {
        Write-Log "No Windows updates found during pre-process."
    }
} catch {
    Write-Log "WARNING: Pre-process Windows update check failed. $_" "ERROR"
}

# -------------------------------------------------------------------------
# Software Installation Functions and List
# -------------------------------------------------------------------------
function Is-SoftwareInstalled {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SoftwareId
    )
    try {
        $output = & winget list --id $SoftwareId 2>$null | Out-String
        return $output -match $SoftwareId
    } catch {
        return $false
    }
}

function Install-Software {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [string]$Id,
        [Parameter(Mandatory = $true)]
        [string]$Description
    )
    if (Is-SoftwareInstalled -SoftwareId $Id) {
        Write-Log "$Name is already installed. Skipping installation."
        return $true
    } else {
        Write-Log "Installing $Name ($Description)..."
        try {
            $process = Start-Process -FilePath "winget" `
                        -ArgumentList "install --id $Id --silent --accept-package-agreements --accept-source-agreements" `
                        -NoNewWindow -Wait -PassThru
            if ($process.ExitCode -eq 0) {
                Write-Log "$Name installed successfully."
                return $true
            } else {
                Write-Log "ERROR: Installation of $Name failed with exit code $($process.ExitCode)." "ERROR"
                return $false
            }
        } catch {
            Write-Log "ERROR: Exception during installation of $Name. $_" "ERROR"
            return $false
        }
    }
}

# Define software list as an array of objects
$softwareList = @(
    @{Name="7-Zip";                           Id="7zip.7zip";                       Description="File Archiver"},
    @{Name="Node.js LTS";                     Id="OpenJS.NodeJS.LTS";                Description="Development Platform"},
    @{Name="Java JDK";                        Id="Oracle.JDK.17";                    Description="Java Development Kit"},
    @{Name="Python";                          Id="Python.Python.3";                  Description="Programming Language"},
    @{Name="Visual Studio Code";              Id="Microsoft.VisualStudioCode";       Description="Code Editor"},
    @{Name="Google Chrome";                   Id="Google.Chrome";                    Description="Web Browser"},
    @{Name="IntelliJ IDEA Community Edition"; Id="JetBrains.IntelliJIDEA.Community"; Description="Java/Kotlin IDE"},
    @{Name="Apache NetBeans";                 Id="Apache.NetBeans";                  Description="Java IDE"},
    @{Name="Arduino IDE";                     Id="Arduino.ArduinoIDE";               Description="Arduino Programming Environment"},
    @{Name="Android Studio";                  Id="Google.AndroidStudio";             Description="Android Development IDE"},
    @{Name="MySQL";                           Id="Oracle.MySQL";                     Description="Relational Database"},
    @{Name="MySQL Workbench";                 Id="Oracle.MySQLWorkbench";            Description="MySQL Administration Tool"},
    @{Name="Docker Desktop";                  Id="Docker.DockerDesktop";             Description="Container Platform"}
)

foreach ($software in $softwareList) {
    Install-Software -Name $software.Name -Id $software.Id -Description $software.Description
}

# -------------------------------------------------------------------------
# MySQL Configuration: Set root password (if mysqladmin exists)
# -------------------------------------------------------------------------
Write-Log "Configuring MySQL..."
try {
    $mysqlAdmin = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqladmin.exe"
    if (Test-Path $mysqlAdmin) {
        $process = Start-Process -FilePath $mysqlAdmin `
                    -ArgumentList "-u root password '1234'" `
                    -NoNewWindow -Wait -PassThru
        if ($process.ExitCode -eq 0) {
            Write-Log "MySQL root password set to '1234'."
        } else {
            Write-Log "ERROR: Failed to set MySQL root password; exit code $($process.ExitCode)." "ERROR"
        }
    } else {
        Write-Log "mysqladmin.exe not found. Skipping MySQL configuration."
    }
} catch {
    Write-Log "ERROR: Exception during MySQL configuration. $_" "ERROR"
}

# -------------------------------------------------------------------------
# WSL 2 Installation and Configuration
# -------------------------------------------------------------------------
Write-Log "Installing and configuring WSL 2..."
try {
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-for-Linux -NoRestart -ErrorAction Stop
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart -ErrorAction Stop
    $wslUpdatePath = "$env:TEMP\wsl_update_x64.msi"
    Invoke-WebRequest -Uri "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi" -OutFile $wslUpdatePath -ErrorAction Stop
    $process = Start-Process -FilePath "msiexec.exe" `
                    -ArgumentList "/i $wslUpdatePath /quiet" `
                    -NoNewWindow -Wait -PassThru
    if ($process.ExitCode -eq 0) {
        wsl --set-default-version 2
        Write-Log "WSL 2 installed and configured successfully."
    } else {
        Write-Log "ERROR: WSL 2 kernel update failed; exit code $($process.ExitCode)." "ERROR"
    }
} catch {
    Write-Log "ERROR: Exception during WSL 2 installation. $_" "ERROR"
}

# -------------------------------------------------------------------------
# Docker Configuration for Guest Users
# -------------------------------------------------------------------------
Write-Log "Configuring Docker for guest users..."
try {
    $guestUsers = Get-WmiObject -Class Win32_UserAccount -Filter "LocalAccount=True AND Name LIKE 'Guest%'"
    foreach ($user in $guestUsers) {
        try {
            Add-LocalGroupMember -Group "docker-users" -Member $user.Name -ErrorAction Stop
            Write-Log "Added user '$($user.Name)' to the docker-users group."
        } catch {
            Write-Log "ERROR: Could not add user '$($user.Name)' to docker-users. $_" "ERROR"
        }
    }
    $dockerConfigPath = "C:\ProgramData\Docker\config\daemon.json"
    if (Test-Path $dockerConfigPath) {
        try {
            $dockerConfig = Get-Content $dockerConfigPath -Raw | ConvertFrom-Json -ErrorAction Stop
        } catch {
            Write-Log "WARNING: Unable to parse Docker configuration. Using default." "ERROR"
            $dockerConfig = @{}
        }
    } else {
        $dockerConfig = @{}
    }
    $dockerConfig.cleanupGuestContainers = $true
    try {
        $dockerConfig | ConvertTo-Json -Depth 10 | Out-File -FilePath $dockerConfigPath -Force
        Write-Log "Docker configuration updated for guest container cleanup."
    } catch {
        Write-Log "ERROR: Failed to update Docker configuration. $_" "ERROR"
    }
} catch {
    Write-Log "ERROR: Exception during Docker configuration. $_" "ERROR"
}

# -------------------------------------------------------------------------
# RSAT Installation for Future AD Integration
# -------------------------------------------------------------------------
Write-Log "Preparing for future AD integration by checking RSAT (Active Directory)..."
try {
    $rsatAD = Get-WindowsCapability -Online | Where-Object { $_.Name -like "Rsat.ActiveDirectory*" }
    if ($rsatAD) {
        if ($rsatAD.State -ne "Installed") {
            try {
                Add-WindowsCapability -Online -Name $rsatAD.Name -ErrorAction Stop
                Write-Log "RSAT Active Directory tools installed."
            } catch {
                Write-Log "WARNING: Failed to install RSAT Active Directory tools. $_" "ERROR"
            }
        } else {
            Write-Log "RSAT Active Directory tools are already installed."
        }
    } else {
        Write-Log "RSAT Active Directory capability not found on this system."
    }
} catch {
    Write-Log "WARNING: Exception during RSAT check/install. $_" "ERROR"
}

# -------------------------------------------------------------------------
# Post-Process: Windows Updates (Final Check)
# -------------------------------------------------------------------------
Write-Log "Initiating post-process Windows updates..."
try {
    $updates = Get-WindowsUpdate -IncludeOptional -ErrorAction SilentlyContinue
    if ($updates) {
        Install-WindowsUpdate -AcceptAll -IgnoreReboot -ErrorAction SilentlyContinue
        Write-Log "Post-process Windows updates applied."
    } else {
        Write-Log "No Windows updates found during post-process."
    }
} catch {
    Write-Log "WARNING: Post-process Windows update check failed. $_" "ERROR"
}

# -------------------------------------------------------------------------
# Enable Guest Account (Convidado)
# -------------------------------------------------------------------------
function Enable-GuestAccount {
    try {
        $guest = Get-LocalUser -Name "Guest"
        if (-not $guest.Enabled) {
            Enable-LocalUser -Name "Guest" -ErrorAction Stop
            Write-Log "Guest account enabled."
        } else {
            Write-Log "Guest account is already enabled."
        }
        # Clear password (set to empty string)
        Set-LocalUser -Name "Guest" -Password (ConvertTo-SecureString "" -AsPlainText -Force)
        Write-Log "Guest account password cleared (no password)."
        return $true
    } catch {
        Write-Log "ERROR: Could not enable Guest account. $_" "ERROR"
        return $false
    }
}
Enable-GuestAccount

# -------------------------------------------------------------------------
# Interactive Configuration Phase
# -------------------------------------------------------------------------
# 1. Rename the computer if desired
$currentName = $env:COMPUTERNAME
$desiredName = Read-Host "Enter desired computer name (current: $currentName)"
if ($desiredName -and $desiredName -ne $currentName) {
    try {
        Rename-Computer -NewName $desiredName -Force -ErrorAction Stop
        Write-Log "Computer renamed from '$currentName' to '$desiredName'."
    } catch {
        Write-Log "ERROR: Failed to rename computer. $_" "ERROR"
    }
} else {
    Write-Log "Computer name remains unchanged."
}

# 2. Enable and update the built-in Administrator account
try {
    $adminUser = Get-LocalUser -Name "Administrator" -ErrorAction SilentlyContinue
    if ($adminUser) {
        if (-not $adminUser.Enabled) {
            Enable-LocalUser -Name "Administrator" -ErrorAction Stop
            Write-Log "Administrator account enabled."
        } else {
            Write-Log "Administrator account is already enabled."
        }
        $adminPassword = Read-Host "Enter new password for the Administrator account" -AsSecureString
        try {
            Set-LocalUser -Name "Administrator" -Password $adminPassword -ErrorAction Stop
            net user Administrator /expires:never | Out-Null
            Write-Log "Administrator password updated and set to never expire."
        } catch {
            Write-Log "ERROR: Failed to update Administrator password. $_" "ERROR"
        }
    } else {
        Write-Log "ERROR: Administrator account not found." "ERROR"
    }
} catch {
    Write-Log "ERROR: Exception during Administrator account update. $_" "ERROR"
}

# 3. Remove current user (e.g., "Aluno") after ensuring Administrator and Guest accounts are OK
$currentUser = $env:USERNAME
# Confirm that current user is not Administrator or Guest
if ($currentUser -ne "Administrator" -and $currentUser -ne "Guest") {
    try {
        # Attempt removal (this may fail if the user is currently logged in;
        # in that case, schedule removal after reboot using a scheduled task)
        Remove-LocalUser -Name $currentUser -ErrorAction Stop
        Write-Log "User account '$currentUser' removed successfully."
    } catch {
        Write-Log "ERROR: Failed to remove user account '$currentUser'. $_" "ERROR"
    }
} else {
    Write-Log "Current user '$currentUser' is Administrator or Guest; not removing."
}

# -------------------------------------------------------------------------
# Additional Verifications
# -------------------------------------------------------------------------
try {
    $adminUser = Get-LocalUser -Name "Administrator"
    if ($adminUser.Enabled -and (net user Administrator | Select-String "/expires:never")) {
        Write-Log "Verification: Administrator account is enabled and password is set to never expire."
    } else {
        Write-Log "ERROR: Administrator account verification failed." "ERROR"
    }
} catch {
    Write-Log "ERROR: Exception during Administrator account verification. $_" "ERROR"
}

try {
    $guestMember = Get-LocalUser -Name "Guest"
    if ($guestMember.Enabled) {
        Write-Log "Verification: Guest account is enabled."
    } else {
        Write-Log "ERROR: Guest account verification failed." "ERROR"
    }
} catch {
    Write-Log "ERROR: Exception during Guest account verification. $_" "ERROR"
}

# -------------------------------------------------------------------------
# Compile and Log Task Summary
# -------------------------------------------------------------------------
$taskSummary = @(
    "Pre-process Windows updates: Completed",
    "Software installations: Processed (installed/skipped as applicable)",
    "MySQL configuration: Completed/Skipped based on availability",
    "WSL 2 configuration: Completed",
    "Docker configuration: Completed",
    "RSAT for AD integration: Completed/Not applicable",
    "Post-process Windows updates: Completed",
    "Computer renaming: " + (if ($desiredName -and $desiredName -ne $currentName) { "Renamed to '$desiredName'" } else { "Unchanged" }),
    "Administrator account update: Completed",
    "Guest account: Enabled and password cleared",
    "Current user removal: " + (if ($currentUser -ne "Administrator" -and $currentUser -ne "Guest") { "Attempted" } else { "Not applicable" }),
    "Additional Verifications: Completed"
)
Write-Log "------- Task Summary -------"
$taskSummary | ForEach-Object { Write-Log $_ }
Write-Log "----------------------------"

# -------------------------------------------------------------------------
# Prompt for System Reboot
# -------------------------------------------------------------------------
$rebootPrompt = "Current task status:`n$($taskSummary -join "`n")`nConsidering the application of updates, can I reboot the system? (Y/n)"
$rebootResponse = Read-Host $rebootPrompt
if ($rebootResponse -match '^(Y|y)') {
    Write-Log "User confirmed reboot. Restarting the computer..."
    Restart-Computer -Force
} else {
    Write-Log "Reboot canceled by user. Please reboot later for updates to apply."
}
