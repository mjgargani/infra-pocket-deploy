# main.ps1
# Script principal de Pós-instalação

# Caminho absoluto para diretório do script
$ScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
. "$ScriptRoot/utils/logging.ps1"

# Importação dos utilitários essenciais (condicionalmente)
foreach ($script in @(
    "$ScriptRoot/utils/cmdlets/install.ps1",
    "$ScriptRoot/utils/cmdlets/exec.ps1"
)) {
    if (Test-Path $script) {
        . $script
    } else {
        Write-Log "O script $script não foi encontrado!" "ERROR"
        exit 1
    }
}

# Execute Preflight
. "$ScriptRoot/tests/utils.ps1"
. "$ScriptRoot/modules/preflight.ps1"

# Execução dos módulos
. "$ScriptRoot/update/powershell.ps1"
#. "$ScriptRoot/update/windows.ps1"
#. "$ScriptRoot/install/software.ps1"
#. "$ScriptRoot/config/gpos.ps1"
#. "$ScriptRoot/config/user.ps1"
