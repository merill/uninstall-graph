function Uninstall-StandaloneModules {
    <#
    .SYNOPSIS
    Uninstalls a list of standalone PowerShell modules by name.

    .DESCRIPTION
    This function finds and removes specific PowerShell modules by name.
    It handles gallery-installed modules via Uninstall-Module and cleans up
    remaining directories. Uses a retry loop for dependency issues.

    .PARAMETER ModuleNames
    Array of module names to uninstall.
    #>

    param(
        [string[]]$ModuleNames
    )

    $iteration = 1
    $maxIterations = 5

    do {
        $allModules = Get-Module -ListAvailable | Where-Object { $_.Name -in $ModuleNames }
        $installedModules = @()
        try {
            $installedModules = Get-InstalledModule | Where-Object { $_.Name -in $ModuleNames }
        }
        catch {
            Write-Verbose "Could not retrieve installed modules list: $($_.Exception.Message)"
        }

        if ($allModules.Count -eq 0 -and $installedModules.Count -eq 0) {
            break
        }

        if ($iteration -gt 1) {
            Write-Host "=== Retry iteration $iteration ===" -ForegroundColor Blue
        }

        # Uninstall gallery-installed modules
        foreach ($module in $installedModules) {
            try {
                Write-Host "$($module.Name) v$($module.Version)" -ForegroundColor Cyan -NoNewline
                Uninstall-Module -Name $module.Name -AllVersions -Force -ErrorAction Stop
                Write-ColorOutput " [*] Uninstalled" -ForegroundColor Green
            }
            catch {
                Write-Verbose " Failed to uninstall $($module.Name): $($_.Exception.Message)"
                try {
                    Uninstall-Module -Name $module.Name -RequiredVersion $module.Version -Force -ErrorAction Stop
                    Write-ColorOutput " [*] Uninstalled" -ForegroundColor Green
                }
                catch {
                    Write-ColorOutput " [~] Pending directory clean up" -ForegroundColor Green
                    Write-Verbose "   Uninstall-Module for $($module.Name) did not work. Will complete in directory removal. $($_.Exception.Message)"
                }
            }
        }

        # Clean up remaining directories
        if ($allModules.Count -gt 0) {
            Remove-ModuleDirectories -Modules $allModules
        }

        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
        Start-Sleep -Seconds 1

        $iteration++
        if ($iteration -gt $maxIterations) {
            $remaining = Get-Module -ListAvailable | Where-Object { $_.Name -in $ModuleNames }
            if ($remaining.Count -gt 0) {
                Write-Warning "Some standalone modules may still remain after $maxIterations iterations."
                $remaining | ForEach-Object { Write-Host "  - $($_.Name) ($($_.Version)) at $($_.ModuleBase)" -ForegroundColor Red }
            }
            break
        }
    } while ($true)
}
