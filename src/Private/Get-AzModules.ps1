function Get-AzModules {
    <#
    .SYNOPSIS
    Retrieves Azure PowerShell (Az) modules available in the system.

    .DESCRIPTION
    This function searches for Azure PowerShell (Az.*) modules that are available in the module paths.

    .OUTPUTS
    [System.Management.Automation.PSModuleInfo[]] Array of modules found.
    #>
    [CmdletBinding()]
    param()

    $modules = Get-Module -ListAvailable | Where-Object {
        $_.Name -like "Az.*" -or $_.Name -eq "Az" -or $_.Name -eq "Az.Accounts"
    }
    return $modules
}
