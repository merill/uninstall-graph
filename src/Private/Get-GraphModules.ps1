function Get-GraphModules {
    <#
    .SYNOPSIS
    Retrieves Microsoft Graph and/or Entra modules available in the system.

    .DESCRIPTION
    This function searches for Microsoft Graph and/or Entra PowerShell modules that are available in the module paths.

    .PARAMETER IncludeGraph
    Includes Microsoft.Graph* modules in the search.

    .PARAMETER IncludeEntra
    Includes Microsoft.Entra* modules in the search.

    .OUTPUTS
    [System.Management.Automation.PSModuleInfo[]] Array of modules found.
    #>
    [CmdletBinding()]
    param(
        [switch]$IncludeGraph = $true,
        [switch]$IncludeEntra
    )

    $modules = Get-Module -ListAvailable | Where-Object {
        ($IncludeGraph -and ($_.Name -like "Microsoft.Graph*" -or $_.Name -eq "Microsoft.Graph")) -or
        ($IncludeEntra -and $_.Name -like "Microsoft.Entra*")
    }
    return $modules
}
