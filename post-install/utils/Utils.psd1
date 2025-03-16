@{
  # Module manifest for module 'Utils'
  ModuleVersion = '1.0.0'
  GUID = 'd9b1a5e1-5b6a-4f3b-8b2e-2e4d2e4d2e4d'
  Author = 'Rodrigo Gargani Oliveira'
  CompanyName = 'mjgarganis Lab'
  Copyright = '(c) 2025 mjgarganis Lab. All rights reserved.'
  Description = 'Utility module for post-install script'
  PowerShellVersion = '5.1'
  FunctionsToExport = @('Write-Log', 'Get-ResourceStatus', 'Install-Resource')
  FileList = @('logging.ps1', 'get-resource-status.ps1', 'install-resource.ps1')
  RequiredModules = @()
  RequiredAssemblies = @()
  ScriptsToProcess = @()
  TypesToProcess = @()
  FormatsToProcess = @()
  NestedModules = @()
  PrivateData = @{
      PSData = @{
          Tags = @('Utility', 'Post-Install')
          LicenseUri = 'https://opensource.org/licenses/MIT'
          ProjectUri = 'https://github.com/mjgargani/e053-etec-peg/tree/main/post-install'
          IconUri = 'https://github.com/mjgargani/lab/blob/main/public/logo192.png?raw=true'
      }
  }
}