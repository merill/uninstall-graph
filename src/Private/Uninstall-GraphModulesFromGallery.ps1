function Uninstall-GraphModulesFromGallery {
    <#
    .SYNOPSIS
    Uninstalls Microsoft Graph modules using the Uninstall-Module cmdlet.

    .DESCRIPTION
    This function attempts to cleanly uninstall Microsoft Graph modules that were installed from PowerShell Gallery.

    .PARAMETER InstalledModules
    Array of installed module objects to uninstall.

    .PARAMETER Force
    Forces the uninstallation without prompting for confirmation.
    #>

    param(
        [array]$InstalledModules,
        [switch]$Force
    )

    foreach ($module in $InstalledModules) {
        try {
            Write-Host "$($module.Name) v$($module.Version)" -ForegroundColor Cyan -NoNewline

            if ($Force) {
                Uninstall-Module -Name $module.Name -RequiredVersion $module.Version -Force -ErrorAction Stop
            }
            else {
                Uninstall-Module -Name $module.Name -RequiredVersion $module.Version -ErrorAction Stop
            }

            Write-Host " ✅ Uninstalled." -ForegroundColor Green
        }
        catch {
            Write-Verbose " Failed to uninstall $($module.Name): $($_.Exception.Message)"

            # Try uninstalling all versions
            try {
                Write-Verbose " Attempting to uninstall all versions of $($module.Name)" -ForegroundColor Yellow
                if ($Force) {
                    Uninstall-Module -Name $module.Name -AllVersions -Force -ErrorAction Stop
                }
                else {
                    Uninstall-Module -Name $module.Name -AllVersions -ErrorAction Stop
                }
                Write-Host " ✅ Uninstalled." -ForegroundColor Green
            }
            catch {
                Write-Host " ⌛ Pending directory clean up." -ForegroundColor Green
                Write-Verbose "   Uninstall-Module for $($module.Name) did not work. Will complete in module directory removal. $($_.Exception.Message)"
            }
        }
    }
}