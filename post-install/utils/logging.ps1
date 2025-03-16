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
    Write-Log "Operation completed"
    Write-Log "[ERROR] Operation canceled" "ERROR"
.NOTES
    File Name      : ./utils/logging.ps1
    Author         : Rodrigo Gargani Oliveira
    Prerequisite   : >= PowerShell 5.1.19041.5607 (Desktop)
#>

# Ensure the logs directory exists.
[string]$logsDir = Join-Path $global:ScriptRoot "logs"
if (-not (Test-Path $logsDir)) {
    New-Item -ItemType Directory -Path $logsDir | Out-Null
}

# Generate a timestamp for the log file name.
[string]$global:LogTimestamp = Get-Date -Format "yyyyMMdd_HHmmss"
[string]$global:LogFile = Join-Path -Path $logsDir -ChildPath "$global:LogTimestamp.log"

# Function: Write-Log
function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter()]
        [ValidateSet("INFO", "SUCCESS", "WARN", "ERROR")]
        [string]$Type = "INFO"
    )

    [string]$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    [string]$logMessage = "[$timestamp] [$Type] $Message"

    # Define the hash table of background colors for each log type.
    $backgroundColors = @{
        "SUCCESS" = "Green"
        "ERROR"   = "Red"
        "WARN"    = "Yellow"
        "INFO"    = "White"
    }

    # Obtain the background color based on the log type.
    [string]$backgroundColor = $backgroundColors[$Type]

    # Output to console and append to the single log file.
    Write-Host $logMessage -BackgroundColor $backgroundColor -ForegroundColor Black
    Add-Content -Path $global:LogFile -Value $logMessage
}

# Export the Write-Log function
Export-ModuleMember -Function Write-Log