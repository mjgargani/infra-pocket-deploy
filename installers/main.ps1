param(
    [ValidateSet("install", "uninstall")]
    [string]$Action
)

$installersPath = "$PSScriptRoot"
$installerScripts = Get-ChildItem -Path $installersPath -Filter "software*.ps1" | Sort-Object Name

foreach ($script in $installerScripts) {
    if ($Action -eq "install") {
        Write-Host "Installing using $($script.Name)..."
        & "$($script.FullName)" -Action install
    }
    elseif ($Action -eq "uninstall") {
        Write-Host "Uninstalling using $($script.Name)..."
        & "$($script.FullName)" -Action uninstall
    }
}

Write-Host "Operation completed."
