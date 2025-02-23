# Execute a preflight check
. "$PSScriptRoot\modules\preflight.ps1"

# Import all utility functions
. "$PSScriptRoot\utils\logging.ps1"
. "$PSScriptRoot\utils\cmdlet\install.ps1"
. "$PSScriptRoot\utils\cmdlet\exec.ps1"
. "$PSScriptRoot\utils\tests.ps1"

# Execute all modules
. "$PSScriptRoot\modules\tests\utils.ps1"
# . "$PSScriptRoot\modules\update\powershell.ps1"
# . "$PSScriptRoot\modules\update\windows.ps1"
# . "$PSScriptRoot\modules\install\software.ps1"
# . "$PSScriptRoot\modules\config\gpos.ps1"
# . "$PSScriptRoot\modules\config\user.ps1"
