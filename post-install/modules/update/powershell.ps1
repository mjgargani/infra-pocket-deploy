# modules/update/powershell.ps1
<#
    Este módulo verifica se a versão atual do PowerShell é a última disponível.
    Caso não seja, ele utiliza o Windows Package Manager (winget) para atualizar o PowerShell.
    Atenção: Após a atualização, será necessário reiniciar a sessão para que a nova versão seja aplicada.
#>

Write-Log "Verificando a versão atual do PowerShell..."
$currentVersion = $PSVersionTable.PSVersion
Write-Log "Versão atual do PowerShell: $currentVersion"

Write-Log "Verificando atualizações do PowerShell via winget..."
try {
    # Executa o comando winget para listar atualizações do PowerShell
    $upgradeOutput = winget upgrade --id Microsoft.Powershell --accept-package-agreements --accept-source-agreements 2>&1

    if ($upgradeOutput -match "No applicable update found") {
        Write-Log "PowerShell já está na versão mais recente."
    }
    else {
        Write-Log "Atualização do PowerShell detectada. Iniciando processo de atualização..."
        $upgradeProcess = Start-Process -FilePath "winget" `
                            -ArgumentList "upgrade --id Microsoft.Powershell --accept-package-agreements --accept-source-agreements" `
                            -NoNewWindow -Wait -PassThru

        if ($upgradeProcess.ExitCode -eq 0) {
            Write-Log "PowerShell atualizado com sucesso. Reinicie a sessão para aplicar a nova versão."
        }
        else {
            Write-Log "Erro ao atualizar o PowerShell. Código de saída: $($upgradeProcess.ExitCode)" "ERROR"
        }
    }
}
catch {
    Write-Log "Erro ao verificar/atualizar o PowerShell: $_" "ERROR"
}
