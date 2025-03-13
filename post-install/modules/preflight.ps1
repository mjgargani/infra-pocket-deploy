# post-install/modules/preflight.ps1
<#
    Pre-flight Module
    This module ensures that the script is executed with administrator privileges
    and that the execution policy is set to "Bypass" if the current policy is too restrictive.
    If the conditions are not met, the script will relaunch itself with the proper parameters.
#>

# Check for Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "This script must be run as an Administrator. Please re-run it with elevated privileges."
    exit 1
}

# Check if the current execution policy is too restrictive (e.g., "Restricted")
$currentPolicy = Get-ExecutionPolicy
if ($currentPolicy -eq "Restricted") {
    Write-Host "Execution policy is '$currentPolicy'. Adjusting policy..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
}

Write-Host "Pre-flight checks passed. Running as Administrator with an appropriate execution policy."
