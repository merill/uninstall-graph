function Get-AzureRMModules {
    <#
    .SYNOPSIS
    Retrieves legacy AzureRM PowerShell modules available in the system.

    .DESCRIPTION
    This function searches for legacy AzureRM PowerShell modules that are available in the module paths.
    This includes AzureRM.*, Azure.Storage, and Azure.AnalysisServices modules.

    .OUTPUTS
    [System.Management.Automation.PSModuleInfo[]] Array of modules found.
    #>
    [CmdletBinding()]
    param()

    $modules = Get-Module -ListAvailable | Where-Object {
        $_.Name -like "AzureRM.*" -or $_.Name -eq "AzureRM" -or
        $_.Name -eq "Azure.Storage" -or $_.Name -eq "Azure.AnalysisServices"
    }
    return $modules
}
