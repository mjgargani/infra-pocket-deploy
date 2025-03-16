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
        Write-Log "The script must be run as Administrator." "ERROR"
        exit 1
    }   
}
catch {
    Write-Log "The script must be run in a Windows environment with Administrator privileges." "ERROR"
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
        Invoke-WebRequest -Uri https://aka.ms/get-winget -OutFile winget.msixbundle
        Add-AppxPackage winget.msixbundle
        Remove-Item winget.msixbundle
        Write-Log "winget installed successfully." "SUCCESS"
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
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
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
        Write-Log "Updating PowerShell to the latest version..."
        winget install --id Microsoft.Powershell --silent --accept-package-agreements --accept-source-agreements
        Write-Log "PowerShell updated successfully." "SUCCESS"
    } else {
        Write-Log "PowerShell is already up to date." "WARN"
    }
}
catch {
    Write-Log "Error updating PowerShell. Details: $($_.Exception.Message)" "ERROR"
}

Write-Log "Preflight checks completed successfully." "SUCCESS"