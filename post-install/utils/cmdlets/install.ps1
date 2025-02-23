<#
.SYNOPSIS
    Installs a specified PowerShell module if it is not already installed.
.DESCRIPTION
    The Install-CmdletModule function checks whether a module is installed and, if not—or if the
    ForceInstall switch is used—installs the module using Install-Module with the specified minimum version.
.PARAMETER ModuleName
    The name of the module to install (e.g., "Pester", "PSWindowsUpdate").
.PARAMETER MinimumVersion
    The minimum required version of the module. Defaults to "0.0.0.0", meaning any version is acceptable.
.PARAMETER ForceInstall
    If specified, forces the installation even if the module is already installed.
.EXAMPLE
    Install-CmdletModule -ModuleName "Pester" -MinimumVersion "5.0.0"
    Installs the Pester module if it is not present or does not meet the minimum version requirement.
.EXAMPLE
    Install-CmdletModule -ModuleName "PSWindowsUpdate" -ForceInstall
    Forces the installation of PSWindowsUpdate regardless of whether it is already installed.
#>
function Install-CmdletModule {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ModuleName,

        [Parameter()]
        [string]$MinimumVersion = "0.0.0.0",

        [Parameter()]
        [switch]$ForceInstall
    )

    # Check if the module is already installed
    $moduleInstalled = Get-Module -ListAvailable -Name $ModuleName -ErrorAction SilentlyContinue

    if ($moduleInstalled -and -not $ForceInstall) {
        Write-Log "Module '$ModuleName' is already installed. Version: $($moduleInstalled.Version)"
    }
    else {
        Write-Log "Installing module '$ModuleName' (Minimum version: $MinimumVersion)..."
        try {
            Install-Module -Name $ModuleName -MinimumVersion $MinimumVersion -Force -Scope CurrentUser -ErrorAction Stop
            Write-Log "Module '$ModuleName' installed successfully."
        }
        catch {
            Write-Log "Error installing module '$ModuleName'. Details: $($_.Exception.Message)" "ERROR"
        }
    }
}
