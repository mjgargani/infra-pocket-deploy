<#
.SYNOPSIS
   Executes a provided script block and logs the process.
.DESCRIPTION
   Invoke-Cmdlet takes a script block and an optional description.
   It logs the description, executes the script block, logs a success message, and returns the result.
   In case of an error, it logs the error details and returns $null.
.PARAMETER CmdletBlock
   The script block containing the command to be executed.
.PARAMETER Description
   An optional description of the command, logged prior to execution. Default is "Invoking command".
.EXAMPLE
   $result = Invoke-Cmdlet -CmdletBlock { Get-Service -Name "wuauserv" } -Description "Fetching Windows Update service status"
   Write-Host $result
#>
function Invoke-Cmdlet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ScriptBlock]$CmdletBlock,

        [Parameter()]
        [string]$Description = "Invoking command"
    )

    Write-Log $Description

    try {
        $result = & $CmdletBlock
        Write-Log "Command executed successfully."
        return $result
    }
    catch {
        Write-Log "Error executing command: $($_.Exception.Message)" "ERROR"
        return $null
    }
}
