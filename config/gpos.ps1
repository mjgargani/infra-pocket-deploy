# modules/config/gpos.ps1
<#
    Este módulo configura as políticas locais (GPOs) necessárias para o ambiente pós-instalação.
    São aplicadas configurações de segurança e personalização por meio de alterações no registro,
    utilizando o cmdlet Set-GPRegistryValue do módulo GroupPolicy.
    
    Exemplos:
    - Desabilitar o Cortana.
    - Configurar (exemplo fictício) o tamanho mínimo de senha.
    
    Nota: Certifique-se de executar com privilégios administrativos e que o RSAT esteja instalado.
#>

Write-Log "Iniciando configuração de GPOs..."

try {
    # Verifica se o cmdlet Set-GPRegistryValue está disponível
    if (-not (Get-Command Set-GPRegistryValue -ErrorAction SilentlyContinue)) {
        Write-Log "O cmdlet Set-GPRegistryValue não está disponível. Certifique-se de que o RSAT esteja instalado." "ERROR"
        return
    }

    # Exemplo 1: Desabilitar o Cortana via GPO
    Write-Log "Desabilitando o Cortana via GPO..."
    Set-GPRegistryValue -Name "Local Group Policy" -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -ValueName "AllowCortana" -Type DWord -Value 0
    Write-Log "Cortana desabilitado com sucesso."

    # Exemplo 2: Configurar política de senha mínima via GPO
    Write-Log "Configurando política de senha mínima via GPO..."
    # Este é um exemplo ilustrativo; a configuração real de políticas de senha costuma ser aplicada via GPO de domínio.
    Set-GPRegistryValue -Name "Local Group Policy" -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" -ValueName "MinimumPasswordLength" -Type DWord -Value 8
    Write-Log "Política de senha configurada com sucesso."

    Write-Log "Configuração de GPOs concluída com sucesso."
}
catch {
    Write-Log "Erro durante a configuração de GPOs: $_" "ERROR"
}
