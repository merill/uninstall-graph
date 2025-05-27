function Get-GraphModules {
    <#
    .SYNOPSIS
    Retrieves all Microsoft Graph modules available in the system.

    .DESCRIPTION
    This function searches for all Microsoft Graph PowerShell modules that are available in the module paths.

    .OUTPUTS
    [System.Management.Automation.PSModuleInfo[]] Array of Microsoft Graph modules found.
    #>

    $graphModules = Get-Module -ListAvailable | Where-Object {
        $_.Name -like "Microsoft.Graph*" -or
        $_.Name -eq "Microsoft.Graph"
    }
    return $graphModules
}
