<#
.NOTES
    File Name      : ./main.ps1
    Author         : Rodrigo Gargani Oliveira
    Prerequisite   : >= PowerShell 5.1.19041.5607 (Desktop)
.SYNOPSIS
    Post-install main script.
.DESCRIPTION
    This script is responsible for importing the necessary utility modules and executing the main post-install script.
#>

# Global absolute path to the directory where the script is located
[string]$global:ScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

# Import utility module
Import-Module (Join-Path -Path $global:ScriptRoot -ChildPath "utils/Utils.psd1")

# Main post-install script
Write-Log -Message "Post-install script started" -Type "SUCCESS"
# ...
Write-Log -Message "Post-install script completed" -Type "SUCCESS"