<#
.SYNOPSIS
    Provides logging functionality for the post-install script.
.DESCRIPTION
    This module creates a single log file in the ./logs directory with a filename based on the current timestamp.
    All log messages (INFO or ERROR) are written to this file.
.PARAMETER Message
    The log message to write.
.PARAMETER Type
    The type of log message. Acceptable values are "INFO" or "ERROR". Default is "INFO".
.EXAMPLE
    Write-Log -Message "Operation started" -Type "INFO"
    Write-Log -Message "An error occurred while processing the data" -Type "ERROR"
#>

# Ensure the logs directory exists.
$logsDir = Join-Path $PSScriptRoot "../logs"
if (-not (Test-Path $logsDir)) {
    New-Item -ItemType Directory -Path $logsDir | Out-Null
}

# Generate a timestamp for the log file name.
$global:LogTimestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$global:LogFile = Join-Path $logsDir "$global:LogTimestamp.log"

# Function: Write-Log
function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter()]
        [ValidateSet("INFO", "ERROR")]
        [string]$Type = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Type] $Message"

    # Output to console and append to the single log file.
    Write-Host $logMessage
    Add-Content -Path $global:LogFile -Value $logMessage
}
