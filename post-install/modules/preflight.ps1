# modules/preflight.ps1
<#
    Pre-flight Module
    Este módulo garante privilégios administrativos e políticas de execução adequadas.
#>

# Checar privilégios administrativos
try {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Log "O script precisa ser executado como Administrador." "ERROR"
        exit 1
    }   
}
catch {
    Write-Log "O script precisa ser executado em ambientes Windows, como Administrador." "ERROR"
    exit 1
}

# Checar e ajustar ExecutionPolicy se necessário
$currentPolicy = Get-ExecutionPolicy
if ($currentPolicy -in @("Restricted", "RemoteSigned", "AllSigned")) {
    Write-Log "A ExecutionPolicy atual é '$currentPolicy'. Ajustando para Bypass na sessão atual..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
} else {
    Write-Log "ExecutionPolicy atual é '$currentPolicy'. Nenhuma ação necessária."
}

Write-Log "Preflight concluído com sucesso."
