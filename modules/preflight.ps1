<#
.SYNOPSIS
    Pre-flight checks to ensure administrative privileges and appropriate execution policies.
.DESCRIPTION
    This module ensures that the script is run with administrative privileges and that the execution policy is set to allow script execution.
.NOTES
    File Name: ./modules/preflight.ps1
    Author: Rodrigo Gargani Oliveira
    Prerequisite   : >= PowerShell 5.1.19041.5607 (Desktop)
#>

# Check for administrative privileges
try {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "The script must be run as Administrator."
    }   
}
catch {
    Write-Log "The script must be run in a Windows environment with Administrator privileges." "ERROR"
    break
    exit 1
}

# Check and adjust ExecutionPolicy if necessary
$currentPolicy = Get-ExecutionPolicy
if ($currentPolicy -in @("Restricted", "RemoteSigned", "AllSigned")) {
    Write-Log "The current ExecutionPolicy is '$currentPolicy'. Adjusting to Bypass for the current session..." "WARN"
    Set-ExecutionPolicy Bypass -Scope Process -Force
} else {
    Write-Log "The current ExecutionPolicy is '$currentPolicy'. No action needed."
}

# Ensure winget, chocolatey are installed and up to date
# Ensure PowerShell is updated to the latest version

# Check and install/update winget
try {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Log "Installing winget..."
        Install-PackageProvider -Name NuGet -Force | Out-Null
        Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery -Scope AllUsers | Out-Null
        Write-Log "Using Repair-WinGetPackageManager cmdlet to bootstrap WinGet..."
        Repair-WinGetPackageManager
        Write-Log "winget installed successfully" "SUCCESS"
    } else {
        Write-Log "winget is already installed." "WARN"
    }
}
catch {
    Write-Log "Error installing winget. Details: $($_.Exception.Message)" "ERROR"
}

# Check and install/update chocolatey
try {
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Log "Installing chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force | Out-Null
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) | Out-Null
        Write-Log "chocolatey installed successfully." "SUCCESS"
    } else {
        Write-Log "chocolatey is already installed." "WARN"
    }
}
catch {
    Write-Log "Error installing chocolatey. Details: $($_.Exception.Message)" "ERROR"
}

# Check and update PowerShell
try {
    $psVersion = $PSVersionTable.PSVersion
    if ($psVersion.Major -lt 7) {
        Write-Log "PowerShell version $psVersion detected, starting upgrade via winget."

        # Accept the license agreements and disable interactivity
        $wingetArgs = "upgrade --id Microsoft.PowerShell --accept-package-agreements --accept-source-agreements --disable-interactivity --silent"

        $upgradeProcess = Start-Process winget `
            -ArgumentList $wingetArgs `
            -NoNewWindow -Wait -PassThru -ErrorAction Stop | Out-Null

        if ($upgradeProcess.ExitCode -eq 0) {
            Write-Log "PowerShell successfully updated via winget." "SUCCESS"
        } else {
            throw "Winget exited with error code $($upgradeProcess.ExitCode)."
        }
    } else {
        Write-Log "PowerShell is already up to date (version $psVersion)." "INFO"
    }
} catch {
    Write-Log "Winget failed to upgrade PowerShell. Attempting Chocolatey..." "WARN"
    
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        try {
            $chocoProcess = Start-Process choco -ArgumentList "upgrade powershell-core -y" -NoNewWindow -Wait -PassThru | Out-Null
            if ($chocoProcess.ExitCode -eq 0) {
                Write-Log "PowerShell successfully updated via Chocolatey." "SUCCESS"
            } else {
                throw "Chocolatey exited with error code $($chocoProcess.ExitCode)."
            }
        } catch {
            Write-Log "Error updating PowerShell via Chocolatey: $($_.Exception.Message)" "ERROR"
        }
    } else {
        Write-Log "Chocolatey is not installed. Cannot update PowerShell." "ERROR"
        Write-Log "Error updating PowerShell: $($_.Exception.Message)" "ERROR"
    }
}

Write-Log "Preflight checks completed successfully." "SUCCESS"