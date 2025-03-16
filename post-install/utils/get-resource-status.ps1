<#
.SYNOPSIS
    Checks whether a specified PowerShell module or software is installed.
.DESCRIPTION
    The Get-ResourceStatus function checks if a specified PowerShell module or software is installed on the system.
    It returns a boolean value indicating the installation status.
.PARAMETER ResourceName
    The name of the resource to check (e.g., "firefox").
.PARAMETER ModuleName
    The name of the PowerShell module to check (e.g., "Pester", "PSWindowsUpdate").
.EXAMPLE
    Get-ResourceStatus -ResourceName "firefox"
    Checks if the software "firefox" is installed.
.EXAMPLE
    Get-ResourceStatus -ModuleName "Pester"
    Checks if the PowerShell module "Pester" is installed.
.NOTES
    File Name: ./utils/get-resource-status.ps1
    Author: Rodrigo Gargani Oliveira
    Prerequisite: PowerShell 5.1 or higher
#>

function Get-ResourceStatus {
  [CmdletBinding()]
  param(
      [Parameter(Position = 0, Mandatory = $true, ParameterSetName = 'Software')]
      [string]$ResourceName,

      [Parameter(Position = 1, Mandatory = $true, ParameterSetName = 'Module')]
      [string]$ModuleName
  )

  # Check if the specified PowerShell module is installed
  if ($PSCmdlet.ParameterSetName -eq 'Module') {
      [PSModuleInfo]$module = Get-Module -ListAvailable -Name $ModuleName -ErrorAction SilentlyContinue
      return $null -ne $module
  }
  # Check if the specified software is installed
  elseif ($PSCmdlet.ParameterSetName -eq 'Software') {
      [System.Management.Automation.CommandInfo]$software = Get-Command $ResourceName -ErrorAction SilentlyContinue
      return $null -ne $software
  }
}

# Export the Get-ResourceStatus function
Export-ModuleMember -Function Get-ResourceStatus