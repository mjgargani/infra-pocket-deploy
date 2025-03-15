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

. (Join-Path -Path $global:ScriptRoot -ChildPath "utils/import.ps1") # Import utility scripts