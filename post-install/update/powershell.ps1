# modules/update/powershell.ps1
<##
    Módulo para atualização do PowerShell usando Winget e Chocolatey como fallback.
    Usa cache local (offline-first) para garantir maior eficiência.
#>

# Importa os módulos utilitários necessários
foreach ($script in @(
    "$PSScriptRoot/../../utils/logging.ps1",
    "$PSScriptRoot/../../utils/cmdlets/install.ps1",
    "$PSScriptRoot/../../utils/cmdlets/exec.ps1"
)) {
    if (Test-Path $script) { . $script }
    else {
        Write-Host "[ERRO] Script essencial $script não encontrado." -ForegroundColor Red
        exit 1
    }
}

# Verifica se o script está sendo executado em ambiente Windows
if ($PSVersionTable.OS -notmatch "Windows") {
    Write-Log "Este script é compatível apenas com Windows." "ERROR"
    exit 1
}

Write-Log "Verificando versão atual do PowerShell..."
$currentVersion = $PSVersionTable.PSVersion
Write-Log "Versão atual do PowerShell: $currentVersion"

# Atualização via Winget
function Update-PowerShellWinget {
    Write-Log "Tentando atualizar o PowerShell via Winget..."

    $wingetResult = winget upgrade --id Microsoft.PowerShell --accept-package-agreements --accept-source-agreements 2>&1

    if ($wingetResult -match "No applicable update found") {
        Write-Log "PowerShell já está atualizado (winget)." "INFO"
        return $true
    }

    $process = Start-Process winget -ArgumentList "upgrade --id Microsoft.PowerShell --accept-package-agreements --accept-source-agreements" -NoNewWindow -Wait -PassThru

    if ($process.ExitCode -eq 0) {
        Write-Log "PowerShell atualizado com sucesso via Winget." "SUCCESS"
        return $true
    }
    else {
        Write-Log "Winget falhou com código: $($process.ExitCode)" "ERROR"
        return $false
    }
}

# Atualização via Chocolatey (fallback)
function Update-PowerShellChoco {
    Write-Log "Tentando atualizar o PowerShell via Chocolatey (fallback)..."

    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Log "Chocolatey não está disponível." "ERROR"
        return $false
    }

    $process = Start-Process choco -ArgumentList "upgrade powershell -y" -NoNewWindow -Wait -PassThru

    if ($process.ExitCode -eq 0) {
        Write-Log "PowerShell atualizado via Chocolatey com sucesso." "SUCCESS"
        return $true
    }
    else {
        Write-Log "Erro ao atualizar via Chocolatey. Código: $($process.ExitCode)" "ERROR"
        return $false
    }
}

# Fluxo principal de atualização com fallback
try {
    $updated = Update-PowerShellWinget

    if (-not $updated) {
        $updatedChoco = Update-PowerShellChoco
        if (-not $updatedChoco) {
            Write-Log "Falha em atualizar o PowerShell via ambos Winget e Chocolatey." "ERROR"
            exit 1
        }
    }

    Write-Log "Processo de atualização concluído. Reinicie o PowerShell para aplicar alterações." "INFO"
}

# Executa o fluxo
Update-PowerShellWinget
