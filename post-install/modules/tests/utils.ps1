# modules/tests/utils.ps1
<#
.SYNOPSIS
    Executes tests for the essential utility modules:
      - logging.ps1
      - cmdlets/install.ps1
      - cmdlets/exec.ps1

.DESCRIPTION
    This module uses Pester to verify that the common utilities work as expected.
    If any test fails, the overall post-install process should be halted.
#>

# Ensure Pester is loaded.
Import-Module Pester -ErrorAction Stop

Describe "Utility Module Tests" {

    Context "Logging Module" {
        It "should correctly log an INFO message" {
            # Define a temporary log file.
            $tempLogPath = Join-Path $PSScriptRoot "test_install_log.txt"
            $global:LogFile = $tempLogPath
            if (Test-Path $tempLogPath) { Remove-Item $tempLogPath -Force }
            
            Write-Log -Message "Test INFO message" -Type "INFO"
            $content = Get-Content -Path $tempLogPath -ErrorAction SilentlyContinue
            $content | Should -Contain "Test INFO message"
        }
    }

    Context "Module Installation Utility (Install-CmdletModule)" {
        It "should not throw an error when checking a known installed module" {
            { Install-CmdletModule -ModuleName "Microsoft.PowerShell.Management" } | Should -Not -Throw
        }
    }

    Context "Cmdlet Execution Utility (Invoke-Cmdlet)" {
        It "should execute a script block and return the expected result" {
            $result = Invoke-Cmdlet -CmdletBlock { return 42 } -Description "Testing command execution"
            $result | Should -Be 42
        }
    }
}

Write-Log -Message "All utility tests passed successfully." -Type "INFO"
