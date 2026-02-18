function Get-InstalledAzModules {
    <#
    .SYNOPSIS
    Retrieves Azure PowerShell (Az) modules that were installed from PowerShell Gallery.

    .DESCRIPTION
    This function gets a list of Azure PowerShell (Az.*) modules that were installed via Install-Module from PowerShell Gallery.

    .OUTPUTS
    [System.Management.Automation.PSModuleInfo[]] Array of installed modules.
    #>
    [CmdletBinding()]
    param()

    try {
        $installedModules = Get-InstalledModule | Where-Object {
            $_.Name -like "Az.*" -or $_.Name -eq "Az" -or $_.Name -eq "Az.Accounts"
        }
        return $installedModules
    }
    catch {
        Write-Verbose "Could not retrieve installed Az modules list: $($_.Exception.Message)"
        return @()
    }
}
