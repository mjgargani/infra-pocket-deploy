<#
.SYNOPSIS
    Import script.
.DESCRIPTION
    This script is responsible for importing the necessary utility modules.
.NOTES
    File Name      : ./utils/import-utils.ps1
    Author         : Rodrigo Gargani Oliveira
    Prerequisite   : >= PowerShell 5.1.19041.5607 (Desktop)
#>

# Conditional import of the necessary utility modules
$paths = @(
  "utils/logging.ps1", # Need to be imported first
  "utils/get-resource-status.ps1",
  "utils/install-resource.ps1"
)

foreach ($relativePath in $paths) {
    [string]$script = Join-Path -Path $global:ScriptRoot -ChildPath $relativePath
    if (Test-Path $script) { 
      . $script 
      Write-Log -Message "Utility '$script' loaded"
    } else {
      [string]$message = "[ERROR] Utility '$script' not found"
      try {
        Write-Log -Message $message -Type "ERROR"
      } catch {
        Write-Host $message -BackgroundColor Red
        exit 1
      }
      exit 1
    }
}