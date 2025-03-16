# modules/config/user.ps1
<#
    Este módulo realiza a configuração interativa dos usuários para o ambiente pós-instalação.
    As operações incluem:
      1. Renomear o computador (se desejado).
      2. Habilitar e atualizar a conta do Administrador (definir nova senha e configurar para nunca expirar).
      3. Remover o usuário atual (se este não for "Administrator" ou "Guest").
    
    Nota: Execute este script com privilégios administrativos.
#>

Write-Log "Iniciando configuração interativa de usuários..."

# 1. Renomear o computador, se desejado
$currentName = $env:COMPUTERNAME
$desiredName = Read-Host "Digite o novo nome do computador (atual: $currentName) ou pressione ENTER para manter o mesmo"
if ($desiredName -and $desiredName -ne $currentName) {
    try {
        Rename-Computer -NewName $desiredName -Force -ErrorAction Stop
        Write-Log "Computador renomeado de '$currentName' para '$desiredName'."
    }
    catch {
        Write-Log "Erro ao renomear o computador: $_" "ERROR"
    }
} else {
    Write-Log "Nome do computador permanece como '$currentName'."
}

# 2. Configurar a conta do Administrador
try {
    $adminUser = Get-LocalUser -Name "Administrator" -ErrorAction SilentlyContinue
    if ($adminUser) {
        if (-not $adminUser.Enabled) {
            Enable-LocalUser -Name "Administrator" -ErrorAction Stop
            Write-Log "Conta 'Administrator' habilitada."
        }
        else {
            Write-Log "Conta 'Administrator' já está habilitada."
        }
        
        # Solicita a nova senha para o Administrador
        $adminPassword = Read-Host "Digite a nova senha para a conta 'Administrator'" -AsSecureString
        try {
            Set-LocalUser -Name "Administrator" -Password $adminPassword -ErrorAction Stop
            # Configura a conta para que a senha nunca expire (usando o comando 'net user')
            net user Administrator /expires:never | Out-Null
            Write-Log "Senha da conta 'Administrator' atualizada e configurada para nunca expirar."
        }
        catch {
            Write-Log "Erro ao atualizar a senha do 'Administrator': $_" "ERROR"
        }
    }
    else {
        Write-Log "Conta 'Administrator' não encontrada." "ERROR"
    }
}
catch {
    Write-Log "Exceção ao configurar a conta 'Administrator': $_" "ERROR"
}

# 3. Remover o usuário atual, se não for 'Administrator' ou 'Guest'
$currentUser = $env:USERNAME
if ($currentUser -ne "Administrator" -and $currentUser -ne "Guest") {
    try {
        Remove-LocalUser -Name $currentUser -ErrorAction Stop
        Write-Log "Conta de usuário '$currentUser' removida com sucesso."
    }
    catch {
        Write-Log "Erro ao remover a conta de usuário '$currentUser': $_" "ERROR"
    }
}
else {
    Write-Log "Conta de usuário atual '$currentUser' é 'Administrator' ou 'Guest'; remoção não realizada."
}

Write-Log "Configuração interativa de usuários concluída."
