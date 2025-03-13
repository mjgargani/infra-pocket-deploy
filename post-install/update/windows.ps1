# modules/update/windows.ps1
<#
    Este módulo realiza a atualização do Windows.
    Caso o módulo PSWindowsUpdate não esteja disponível, ele tenta instalá-lo.
    Em seguida, importa o módulo, verifica se há atualizações (incluindo opcionais) e as instala.
    
    Após aplicar as atualizações, o sistema é reiniciado automaticamente para aplicar as mudanças.
#>

Write-Log "Iniciando atualização do Windows..."

try {
    # Verifica se o módulo PSWindowsUpdate está disponível; caso contrário, tenta instalá-lo
    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Write-Log "Módulo PSWindowsUpdate não encontrado. Instalando..."
        Install-CmdletModule -ModuleName "PSWindowsUpdate" -ForceInstall
    }

    # Importa o módulo PSWindowsUpdate
    Import-Module PSWindowsUpdate -ErrorAction Stop

    Write-Log "Buscando atualizações do Windows..."
    # Obtém atualizações, incluindo as opcionais
    $updates = Get-WindowsUpdate -IncludeOptional -ErrorAction SilentlyContinue

    if ($updates -and $updates.Count -gt 0) {
        Write-Log "Foram encontradas atualizações. Iniciando instalação..."
        # Instala todas as atualizações e aguarda conclusão
        Install-WindowsUpdate -AcceptAll -ErrorAction Stop
        Write-Log "Atualizações do Windows aplicadas com sucesso."
        
        Write-Log "Reiniciando o sistema para aplicar as atualizações..."
        Restart-Computer -Force
    }
    else {
        Write-Log "Nenhuma atualização do Windows encontrada."
    }
}
catch {
    Write-Log "Erro durante o processo de atualização do Windows: $_" "ERROR"
}
