function Get-InstalledAzureRMModules {
    <#
    .SYNOPSIS
    Retrieves legacy AzureRM modules that were installed from PowerShell Gallery.

    .DESCRIPTION
    This function gets a list of legacy AzureRM modules that were installed via Install-Module from PowerShell Gallery.
    This includes AzureRM.*, Azure.Storage, and Azure.AnalysisServices modules.

    .OUTPUTS
    [System.Management.Automation.PSModuleInfo[]] Array of installed modules.
    #>
    [CmdletBinding()]
    param()

    try {
        $installedModules = Get-InstalledModule | Where-Object {
            $_.Name -like "AzureRM.*" -or $_.Name -eq "AzureRM" -or
            $_.Name -eq "Azure.Storage" -or $_.Name -eq "Azure.AnalysisServices"
        }
        return $installedModules
    }
    catch {
        Write-Verbose "Could not retrieve installed AzureRM modules list: $($_.Exception.Message)"
        return @()
    }
}
