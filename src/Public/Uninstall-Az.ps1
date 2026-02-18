<#
    .SYNOPSIS
    Completely uninstalls and removes all Azure PowerShell (Az) modules from the system.

    .DESCRIPTION
    Azure PowerShell (Az) comes with a large number of modules and the installed versions and dependencies
    can sometimes cause issues when trying to update or reinstall them.

    Uninstalling the Az PowerShell modules can help resolve these issues by ensuring a clean slate.

    However, the uninstallation process can be tricky because Az PowerShell modules
    are often interdependent (e.g. many modules depend on Az.Accounts), making it difficult to remove
    them cleanly in one go using the `Uninstall-Module` cmdlet.

    This function is designed to ensure that all Az modules are thoroughly removed from your system,
    and restore your PowerShell environment to a clean state.

    If legacy AzureRM modules are detected on the system, they will also be automatically removed.

    You can then download and do a fresh install of the latest version of the Az PowerShell modules.

    .PARAMETER SkipAdminCheck
    Skips the administrator privileges check on Windows systems.

    .EXAMPLE
    Uninstall-Az

    Runs the function with default settings to remove all Azure PowerShell (Az) modules.
    Also removes legacy AzureRM modules if detected.

    .EXAMPLE
    Uninstall-Az -SkipAdminCheck

    Runs the function without checking for administrator privileges.
#>
function Uninstall-Az {
    [CmdletBinding()]
    param(
        [switch]$SkipAdminCheck
    )

    # Main execution
    Write-Host "=== Azure PowerShell Module Uninstaller ===" -ForegroundColor Cyan
    Write-Host "This cmdlet will completely remove all Azure PowerShell (Az) modules from your system." -ForegroundColor White
    Write-Host "Legacy AzureRM modules will also be removed if detected." -ForegroundColor White
    Write-Host "If you run into issues, try running with -Verbose for more info." -ForegroundColor White
    Write-Host ""

    # Check if running as administrator on Windows
    if (-not $SkipAdminCheck -and ($PSVersionTable.PSVersion.Major -lt 6 -or ($PSVersionTable.PSVersion.Major -ge 6 -and $IsWindows))) {
        if (-not (Test-IsAdmin)) {
            Write-Error "We recommend running with administrator privileges. If you are unable to run as administrator, please use the -SkipAdminCheck parameter to run without Administrator privileges."
            return
        }
    }

    $iteration = 1
    $maxIterations = 10

    do {
        Write-Host "=== Iteration $iteration ===" -ForegroundColor Blue

        # Get all Az modules (both installed and available)
        $allAzModules = Get-AzModules
        $installedAzModules = Get-InstalledAzModules

        if ($allAzModules.Count -eq 0 -and $installedAzModules.Count -eq 0) {
            Write-ColorOutput "[+] No Azure PowerShell (Az) modules found. Cleanup complete!" -ForegroundColor Green
            break
        }

        Write-Host "Found $($allAzModules.Count) Az modules in module paths" -ForegroundColor White
        Write-Host "Found $($installedAzModules.Count) installed Az modules from PowerShell Gallery" -ForegroundColor White

        # First, try to uninstall using Uninstall-Module for gallery-installed modules
        if ($installedAzModules.Count -gt 0) {
            Write-ColorOutput "`n[x] Uninstalling Az modules using Uninstall-Module..." -ForegroundColor Yellow
            Uninstall-AzModulesFromGallery -InstalledModules $installedAzModules -Force:$Force
        }

        # Then remove any remaining module directories
        if ($allAzModules.Count -gt 0) {
            Write-ColorOutput "`n[-] Cleaning up remaining Az module directories..." -ForegroundColor Yellow
            Remove-ModuleDirectories -Modules $allAzModules
        }

        # Force garbage collection to release any locks
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()

        Start-Sleep -Seconds 2

        $iteration++

        if ($iteration -gt $maxIterations) {
            Write-Warning "Reached maximum iterations ($maxIterations). Some Az modules may still remain."
            $remainingModules = Get-AzModules
            if ($remainingModules.Count -gt 0) {
                Write-Host "`nRemaining modules:" -ForegroundColor Red
                $remainingModules | ForEach-Object { Write-Host "  - $($_.Name) ($($_.Version)) at $($_.ModuleBase)" -ForegroundColor Red }
                Write-Host "`nYou may need to manually remove these modules or restart your PowerShell session." -ForegroundColor Yellow
            }
            break
        }

    } while ($true)

    # === Phase 2: AzureRM legacy modules ===
    $allAzureRMModules = Get-AzureRMModules
    $installedAzureRMModules = Get-InstalledAzureRMModules

    if ($allAzureRMModules.Count -gt 0 -or $installedAzureRMModules.Count -gt 0) {
        Write-Host ""
        Write-Host "=== Legacy AzureRM modules detected ===" -ForegroundColor Cyan
        Write-Host "Found $($allAzureRMModules.Count) AzureRM modules in module paths" -ForegroundColor White
        Write-Host "Found $($installedAzureRMModules.Count) installed AzureRM modules from PowerShell Gallery" -ForegroundColor White
        Write-Host ""

        # Try the Az.Accounts Uninstall-AzureRm cmdlet first (Microsoft's recommended approach)
        $useManualFallback = $true
        $uninstallAzureRmCmd = Get-Command -Name 'Uninstall-AzureRm' -ErrorAction SilentlyContinue
        if ($uninstallAzureRmCmd) {
            Write-ColorOutput "[>] Az.Accounts Uninstall-AzureRm cmdlet found. Attempting recommended removal..." -ForegroundColor Yellow
            try {
                Uninstall-AzureRm -ErrorAction Stop
                Write-ColorOutput "[*] Uninstall-AzureRm completed." -ForegroundColor Green

                # Check if it actually cleaned everything
                $allAzureRMModules = Get-AzureRMModules
                $installedAzureRMModules = Get-InstalledAzureRMModules

                if ($allAzureRMModules.Count -eq 0 -and $installedAzureRMModules.Count -eq 0) {
                    Write-ColorOutput "[+] All legacy AzureRM modules removed by Uninstall-AzureRm." -ForegroundColor Green
                    $useManualFallback = $false
                }
                else {
                    Write-ColorOutput "[!] Some AzureRM modules remain after Uninstall-AzureRm. Falling back to manual cleanup..." -ForegroundColor Yellow
                }
            }
            catch {
                Write-Verbose "Uninstall-AzureRm failed: $($_.Exception.Message)"
                Write-ColorOutput "[!] Uninstall-AzureRm did not succeed. Falling back to manual cleanup..." -ForegroundColor Yellow
            }
        }
        else {
            Write-Verbose "Uninstall-AzureRm cmdlet not available (Az.Accounts not loaded). Using manual cleanup."
        }

        # Manual fallback: iterate to remove AzureRM modules
        if ($useManualFallback) {
            $rmIteration = 1
            $rmMaxIterations = 10

            do {
                Write-Host "=== AzureRM Iteration $rmIteration ===" -ForegroundColor Blue

                $allAzureRMModules = Get-AzureRMModules
                $installedAzureRMModules = Get-InstalledAzureRMModules

                if ($allAzureRMModules.Count -eq 0 -and $installedAzureRMModules.Count -eq 0) {
                    Write-ColorOutput "[+] No legacy AzureRM modules found. Cleanup complete!" -ForegroundColor Green
                    break
                }

                # First, try to uninstall using Uninstall-Module for gallery-installed modules
                if ($installedAzureRMModules.Count -gt 0) {
                    Write-ColorOutput "`n[x] Uninstalling AzureRM modules using Uninstall-Module..." -ForegroundColor Yellow
                    Uninstall-AzureRMModulesFromGallery -InstalledModules $installedAzureRMModules -Force:$Force
                }

                # Then remove any remaining module directories
                if ($allAzureRMModules.Count -gt 0) {
                    Write-ColorOutput "`n[-] Cleaning up remaining AzureRM module directories..." -ForegroundColor Yellow
                    Remove-ModuleDirectories -Modules $allAzureRMModules
                }

                # Force garbage collection to release any locks
                [System.GC]::Collect()
                [System.GC]::WaitForPendingFinalizers()

                Start-Sleep -Seconds 2

                $rmIteration++

                if ($rmIteration -gt $rmMaxIterations) {
                    Write-Warning "Reached maximum iterations ($rmMaxIterations). Some AzureRM modules may still remain."
                    $remainingRMModules = Get-AzureRMModules
                    if ($remainingRMModules.Count -gt 0) {
                        Write-Host "`nRemaining AzureRM modules:" -ForegroundColor Red
                        $remainingRMModules | ForEach-Object { Write-Host "  - $($_.Name) ($($_.Version)) at $($_.ModuleBase)" -ForegroundColor Red }
                        Write-Host "`nYou may need to manually remove these modules or restart your PowerShell session." -ForegroundColor Yellow
                    }
                    break
                }

            } while ($true)
        }
    }

    Write-Host "`n=== Cleanup Summary ===" -ForegroundColor Magenta

    # Final check — Az modules
    $finalAzModules = Get-AzModules
    $finalInstalledModules = Get-InstalledAzModules

    # Final check — AzureRM modules
    $finalAzureRMModules = Get-AzureRMModules
    $finalInstalledAzureRMModules = Get-InstalledAzureRMModules

    $azClean = ($finalAzModules.Count -eq 0 -and $finalInstalledModules.Count -eq 0)
    $azureRMClean = ($finalAzureRMModules.Count -eq 0 -and $finalInstalledAzureRMModules.Count -eq 0)

    if ($azClean -and $azureRMClean) {
        Write-ColorOutput "[*] All Azure PowerShell (Az) modules have been successfully removed!" -ForegroundColor Green
        if ($allAzureRMModules.Count -gt 0 -or $installedAzureRMModules.Count -gt 0) {
            Write-ColorOutput "[*] All legacy AzureRM modules have been successfully removed!" -ForegroundColor Green
        }
        Write-ColorOutput "[*] Your system is now clean of Azure PowerShell modules." -ForegroundColor Green
        Write-ColorOutput "[>] We recommend closing this window and starting a new PowerShell session." -ForegroundColor Green
    }
    else {
        if (-not $azClean) {
            Write-ColorOutput "[!] Some Az modules may still remain:" -ForegroundColor Yellow
            if ($finalAzModules.Count -gt 0) {
                Write-Host "  - $($finalAzModules.Count) Az modules found in module paths" -ForegroundColor Red
            }
            if ($finalInstalledModules.Count -gt 0) {
                Write-Host "  - $($finalInstalledModules.Count) installed Az modules from PowerShell Gallery" -ForegroundColor Red
            }
        }
        if (-not $azureRMClean) {
            Write-ColorOutput "[!] Some AzureRM modules may still remain:" -ForegroundColor Yellow
            if ($finalAzureRMModules.Count -gt 0) {
                Write-Host "  - $($finalAzureRMModules.Count) AzureRM modules found in module paths" -ForegroundColor Red
            }
            if ($finalInstalledAzureRMModules.Count -gt 0) {
                Write-Host "  - $($finalInstalledAzureRMModules.Count) installed AzureRM modules from PowerShell Gallery" -ForegroundColor Red
            }
        }
        Write-Host "  You may need to restart PowerShell and run this script again." -ForegroundColor Yellow
    }
}
