function Uninstall-AzModulesFromGallery {
    <#
    .SYNOPSIS
    Uninstalls Azure PowerShell (Az) modules using the Uninstall-Module cmdlet.

    .DESCRIPTION
    This function attempts to cleanly uninstall Azure PowerShell (Az) modules that were installed from PowerShell Gallery.
    Az.Accounts is uninstalled last because other Az modules depend on it.

    .PARAMETER InstalledModules
    Array of installed module objects to uninstall.

    .PARAMETER Force
    Forces the uninstallation without prompting for confirmation.
    #>

    param(
        [array]$InstalledModules,
        [switch]$Force
    )

    # Uninstall Az.Accounts last since other modules depend on it
    $sortedModules = @()
    $azAccounts = $InstalledModules | Where-Object { $_.Name -eq 'Az.Accounts' }
    $azRoot = $InstalledModules | Where-Object { $_.Name -eq 'Az' }
    $otherModules = $InstalledModules | Where-Object { $_.Name -ne 'Az.Accounts' -and $_.Name -ne 'Az' }

    # Uninstall Az root module first, then other modules, then Az.Accounts last
    if ($azRoot) { $sortedModules += $azRoot }
    $sortedModules += $otherModules
    if ($azAccounts) { $sortedModules += $azAccounts }

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
