function Get-GraphModules {
    <#
    .SYNOPSIS
    Retrieves all Microsoft Graph modules available in the system.

    .DESCRIPTION
    This function searches for all Microsoft Graph PowerShell modules that are available in the module paths.

    .PARAMETER IncludeEntra
    Also includes Microsoft.Entra* modules in the search.

    .OUTPUTS
    [System.Management.Automation.PSModuleInfo[]] Array of Microsoft Graph modules found.
    #>
    [CmdletBinding()]
    param(
        [switch]$IncludeEntra
    )

    $graphModules = Get-Module -ListAvailable | Where-Object {
        $_.Name -like "Microsoft.Graph*" -or
        $_.Name -eq "Microsoft.Graph" -or
        ($IncludeEntra -and $_.Name -like "Microsoft.Entra*")
    }
    return $graphModules
}
