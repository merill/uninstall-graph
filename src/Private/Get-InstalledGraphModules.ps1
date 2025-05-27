function Get-InstalledGraphModules {
    <#
    .SYNOPSIS
    Retrieves Microsoft Graph modules that were installed from PowerShell Gallery.

    .DESCRIPTION
    This function gets a list of Microsoft Graph modules that were installed via Install-Module from PowerShell Gallery.

    .OUTPUTS
    [System.Management.Automation.PSModuleInfo[]] Array of installed Microsoft Graph modules.
    #>

    try {
        $installedModules = Get-InstalledModule | Where-Object {
            $_.Name -like "Microsoft.Graph*" -or
            $_.Name -eq "Microsoft.Graph"
        }
        return $installedModules
    }
    catch {
        Write-Verbose "Could not retrieve installed modules list: $($_.Exception.Message)"
        return @()
    }
}
