<#
.SYNOPSIS
    Installs a specified PowerShell module or software if it is not already installed.
.DESCRIPTION
    The Install-Resource function checks whether a PowerShell module or software is installed and, if not—or if the
    ForceInstall switch is used—installs the resource using Install-Module, winget, or chocolatey with the specified minimum version.
.PARAMETER ResourceName
    The name of the resource to install (e.g., "firefox").
.PARAMETER ModuleName
    The name of the PowerShell module to install (e.g., "Pester", "PSWindowsUpdate").
.PARAMETER PackageId
    The ID of the package to install using winget (e.g., "Mozilla.Firefox").
.PARAMETER ChocoPackageId
    The ID of the package to install using chocolatey (e.g., "firefox").
.PARAMETER MinimumVersion
    The minimum required version of the PowerShell module. Defaults to "0.0.0.0", meaning any version is acceptable.
.PARAMETER ForceInstall
    If specified, forces the installation even if the resource is already installed.
.EXAMPLE
    Install-Resource -ResourceName "firefox" -ModuleName "Pester" -PackageId "Mozilla.Firefox" -ChocoPackageId "firefox" -ForceInstall
    Installs the Pester module, Firefox using winget, or Firefox using chocolatey if they are not present or forces the installation.
.EXAMPLE
    Install-Resource -ResourceName "firefox" -PackageId "Mozilla.Firefox"
    Installs Firefox using winget if it is not present.
.EXAMPLE
    Install-Resource -ResourceName "firefox" -ChocoPackageId "firefox"
    Installs Firefox using chocolatey if it is not present.
.NOTES
    File Name      : ./utils/install-resource.ps1
    Author         : Rodrigo Gargani Oliveira
    Prerequisite   : >= PowerShell 5.1.19041.5607 (Desktop)
#>
function Install-Resource {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName = 'Software')]
        [string]$ResourceName,

        [Parameter(Position = 1, Mandatory = $true, ParameterSetName = 'Module')]
        [string]$ModuleName,

        [Parameter(ParameterSetName = 'Software')]
        [string]$PackageId,

        [Parameter(ParameterSetName = 'Software')]
        [string]$ChocoPackageId,

        [Parameter(ParameterSetName = 'Module')]
        [string]$MinimumVersion = "0.0.0.0",

        [Parameter()]
        [switch]$ForceInstall
    )

    # Verify if the resource is installed
    [bool]$resourceInstalled = Get-ResourceStatus -ResourceName $ResourceName -ModuleName $ModuleName
    if ($resourceInstalled -and -not $ForceInstall) {
        Write-Log "Resource '$ResourceName' is already installed."
    }
    
    else {
        Write-Log "Installing resource '$ResourceName'..."
        try {
            if ($PSCmdlet.ParameterSetName -eq 'Module' -and -not $resourceInstalled) {
                Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
                Install-Module -Name $ModuleName -MinimumVersion $MinimumVersion -Force -Scope AllUsers -ErrorAction Stop
                Write-Log "Module '$ModuleName' installed successfully."
            }
            elseif ($PSCmdlet.ParameterSetName -eq 'Software' -and $PackageId -and -not $resourceInstalled) {
                winget install --id $PackageId --silent --accept-package-agreements --accept-source-agreements
                Write-Log "Software '$ResourceName' installed successfully with winget."
            }
            elseif ($PSCmdlet.ParameterSetName -eq 'Software' -and $ChocoPackageId -and -not $resourceInstalled) {
                choco install $ChocoPackageId -y
                Write-Log "Software '$ResourceName' installed successfully with chocolatey."
            }
        }
        catch {
            Write-Log "Error installing resource '$ResourceName'. Details: $($_.Exception.Message)" "ERROR"
        }
    }
}

# Export Install-Resource cmdlet
Export-ModuleMember -Function Install-Resource