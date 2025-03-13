# modules/install/software.ps1
<#
    Módulo para instalação de softwares essenciais via winget.
    Para cada software na lista, verifica se o software já está instalado
    (utilizando a função Test-SoftwareInstalled) e, se não estiver, realiza a instalação
    por meio da função Install-Software.
    
    É importante que este módulo seja executado após o carregamento dos utilitários
    (logging, etc.) para garantir que as funções Write-Log e Write-TDDLog estejam disponíveis.
#>

# Função para verificar se um software está instalado utilizando winget
function Test-SoftwareInstalled {
  param(
      [Parameter(Mandatory = $true)]
      [string]$SoftwareId
  )
  try {
      $output = winget list --id $SoftwareId 2>$null | Out-String
      return $output -match $SoftwareId
  }
  catch {
      Write-Log "Erro ao verificar instalação do software com id '$SoftwareId': $_" "ERROR"
      return $false
  }
}

# Função para instalar software via winget
function Install-Software {
  param(
      [Parameter(Mandatory = $true)]
      [string]$Name,
      [Parameter(Mandatory = $true)]
      [string]$Id,
      [Parameter(Mandatory = $true)]
      [string]$Description
  )
  if (Test-SoftwareInstalled -SoftwareId $Id) {
      Write-Log "$Name já está instalado. Pulando instalação."
      return $true
  }
  else {
      Write-Log "Instalando $Name ($Description)..."
      try {
          $process = Start-Process -FilePath "winget" `
                      -ArgumentList "install --id $Id --silent --accept-package-agreements --accept-source-agreements" `
                      -NoNewWindow -Wait -PassThru
          if ($process.ExitCode -eq 0) {
              Write-Log "$Name instalado com sucesso."
              return $true
          }
          else {
              # Utiliza formatação de string para evitar problemas com ':' na interpolação
              Write-Log ("Erro na instalação de {0}. Código de saída: {1}" -f $Name, $process.ExitCode) "ERROR"
              return $false
          }
      }
      catch {
          Write-Log "Exceção durante a instalação de $Name : $_" "ERROR"
          return $false
      }
  }
}

# Lista de softwares para instalação
$softwareList = @(
  @{ Name = "7-Zip";                           Id = "7zip.7zip";                       Description = "File Archiver" },
  @{ Name = "Node.js LTS";                     Id = "OpenJS.NodeJS.LTS";                Description = "Development Platform" },
  @{ Name = "Java JDK";                        Id = "Oracle.JDK.17";                    Description = "Java Development Kit" },
  @{ Name = "Python";                          Id = "Python.Python.3";                  Description = "Programming Language" },
  @{ Name = "Visual Studio Code";              Id = "Microsoft.VisualStudioCode";       Description = "Code Editor" },
  @{ Name = "Google Chrome";                   Id = "Google.Chrome";                    Description = "Web Browser" },
  @{ Name = "IntelliJ IDEA Community Edition"; Id = "JetBrains.IntelliJIDEA.Community"; Description = "Java/Kotlin IDE" },
  @{ Name = "Apache NetBeans";                 Id = "Apache.NetBeans";                  Description = "Java IDE" },
  @{ Name = "Arduino IDE";                     Id = "Arduino.ArduinoIDE";               Description = "Arduino Programming Environment" },
  @{ Name = "Android Studio";                  Id = "Google.AndroidStudio";             Description = "Android Development IDE" },
  @{ Name = "MySQL";                           Id = "Oracle.MySQL";                     Description = "Relational Database" },
  @{ Name = "MySQL Workbench";                 Id = "Oracle.MySQLWorkbench";            Description = "MySQL Administration Tool" },
  @{ Name = "Docker Desktop";                  Id = "Docker.DockerDesktop";             Description = "Container Platform" }
)

# Itera sobre a lista e instala cada software
foreach ($software in $softwareList) {
  Install-Software -Name $software.Name -Id $software.Id -Description $software.Description
}

Write-Log "Processo de instalação de softwares concluído."
