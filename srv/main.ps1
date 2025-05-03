function Show-Menu {
  Clear-Host
  Write-Host "Select operation:`n"
  Write-Host "0. Run Everything"
  Write-Host "1. Software Installation"
  Write-Host "2. Software Uninstallation"
  Write-Host "3. User Operation"
  Write-Host "4. GPO Operation"
  Write-Host "5. User Reset"
  Write-Host "6. Exit"
}

function Confirm-Action($action) {
  $confirmation = Read-Host "Confirm '$action'? (y/N)"
  return $confirmation -eq 'y'
}

function Run-All {
  if (Confirm-Action "Run Everything") {
      & "$PSScriptRoot\installers\main.ps1"
  }
}

function Install-Software {
  if (Confirm-Action "Install Software") {
      & "$PSScriptRoot\installers\main.ps1" -Action "install"
  }
}

function Uninstall-Software {
  if (Confirm-Action "Uninstall Software") {
      & "$PSScriptRoot\installers\main.ps1" -Action "uninstall"
  }
}

function User-Operation {
  if (Confirm-Action "User Operation") {
      & "$PSScriptRoot\ops\user.ps1"
  }
}

function GPO-Operation {
  if (Confirm-Action "GPO Operation") {
      & "$PSScriptRoot\ops\gpo.ps1"
  }
}

function User-Reset {
  if (Confirm-Action "User Reset") {
      & "$PSScriptRoot\ops\reset.ps1"
  }
}

while ($true) {
  Show-Menu
  $choice = Read-Host "Enter choice [0-6]"
  switch ($choice) {
      "0" { Run-All }
      "1" { Install-Software }
      "2" { Uninstall-Software }
      "3" { User-Operation }
      "4" { GPO-Operation }
      "5" { User-Reset }
      "6" { break }
      default { Write-Host "Invalid selection, try again." }
  }
  Write-Host "Press any key to continue..."
  [void][System.Console]::ReadKey($true)
}
