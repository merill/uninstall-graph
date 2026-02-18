function Uninstall-AzureRMModulesFromGallery {
    <#
    .SYNOPSIS
    Uninstalls legacy AzureRM modules using the Uninstall-Module cmdlet.

    .DESCRIPTION
    This function attempts to cleanly uninstall legacy AzureRM modules that were installed from PowerShell Gallery.
    AzureRM.Profile is uninstalled last because other AzureRM modules depend on it.

    .PARAMETER InstalledModules
    Array of installed module objects to uninstall.

    .PARAMETER Force
    Forces the uninstallation without prompting for confirmation.
    #>

    param(
        [array]$InstalledModules,
        [switch]$Force
    )

    # Uninstall AzureRM.Profile last since other modules depend on it
    $sortedModules = @()
    $azureRMProfile = $InstalledModules | Where-Object { $_.Name -eq 'AzureRM.Profile' }
    $azureRMRoot = $InstalledModules | Where-Object { $_.Name -eq 'AzureRM' }
    $otherModules = $InstalledModules | Where-Object { $_.Name -ne 'AzureRM.Profile' -and $_.Name -ne 'AzureRM' }

    # Uninstall AzureRM root module first, then other modules, then AzureRM.Profile last
    if ($azureRMRoot) { $sortedModules += $azureRMRoot }
    $sortedModules += $otherModules
    if ($azureRMProfile) { $sortedModules += $azureRMProfile }

    foreach ($module in $sortedModules) {
        try {
            Write-Host "$($module.Name) v$($module.Version)" -ForegroundColor Cyan -NoNewline

            if ($Force) {
                Uninstall-Module -Name $module.Name -RequiredVersion $module.Version -Force -ErrorAction Stop
            }
            else {
                Uninstall-Module -Name $module.Name -RequiredVersion $module.Version -ErrorAction Stop
            }

            Write-ColorOutput " [*] Uninstalled" -ForegroundColor Green
        }
        catch {
            Write-Verbose " Failed to uninstall $($module.Name): $($_.Exception.Message)"

            # Try uninstalling all versions
            try {
                Write-Verbose " Attempting to uninstall all versions of $($module.Name)"
                if ($Force) {
                    Uninstall-Module -Name $module.Name -AllVersions -Force -ErrorAction Stop
                }
                else {
                    Uninstall-Module -Name $module.Name -AllVersions -ErrorAction Stop
                }
                Write-ColorOutput " [*] Uninstalled" -ForegroundColor Green
            }
            catch {
                Write-ColorOutput " [~] Pending directory clean up" -ForegroundColor Green
                Write-Verbose "   Uninstall-Module for $($module.Name) did not work. Will complete in module directory removal. $($_.Exception.Message)"
            }
        }
    }
}
