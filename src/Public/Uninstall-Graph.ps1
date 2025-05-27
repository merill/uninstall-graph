<#
    .SYNOPSIS
    Completely uninstalls and removes all Microsoft Graph PowerShell modules from the system.

    .DESCRIPTION
    Microsoft Graph comes with a large number of modules and the installed versions and dependencies can sometimes cause issues when trying to update or reinstall them.

    Another side effect is seeing multiple authentication prompts when using Microsoft Graph cmdlets, which can be frustrating.

    Uninstalling the Microsoft Graph PowerShell modules can help resolve these issues by ensuring a clean slate.

    However, the uninstallation process can be tricky because Microsoft Graph PowerShell modules
    are often interdependent, making it difficult to remove them cleanly in one go using the `Uninstall-Module` cmdlet.

    This function is designed to ensure that all Microsoft Graph modules are thoroughly removed from your system,
    and restore your PowerShell environment to a clean state.

    You can then download and do a fresh install of the latest version of Microsoft Graph PowerShell modules.

    .PARAMETER SkipAdminCheck
    Skips the administrator privileges check on Windows systems.

    .EXAMPLE
    Uninstall-Graph

    Runs the function with default settings.

    .EXAMPLE
    Uninstall-Graph -SkipAdminCheck

    Runs the function without checking for administrator privileges.
#>
function Uninstall-Graph {
    [CmdletBinding()]
    param(
        [switch]$SkipAdminCheck
    )

    # Main execution
    Write-Host "=== Microsoft Graph PowerShell Module Uninstaller ===" -ForegroundColor Magenta
    Write-Host "This function will completely remove all Microsoft Graph PowerShell modules from your system." -ForegroundColor White
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

        # Get all Graph modules (both installed and available)
        $allGraphModules = Get-GraphModules
        $installedGraphModules = Get-InstalledGraphModules

        if ($allGraphModules.Count -eq 0 -and $installedGraphModules.Count -eq 0) {
            Write-Host "No Microsoft Graph modules found. Cleanup complete!" -ForegroundColor Green
            break
        }

        Write-Host "Found $($allGraphModules.Count) Graph modules in module paths" -ForegroundColor White
        Write-Host "Found $($installedGraphModules.Count) installed Graph modules from PowerShell Gallery" -ForegroundColor White

        # First, try to uninstall using Uninstall-Module for gallery-installed modules
        if ($installedGraphModules.Count -gt 0) {
            Write-Host "`nUninstalling modules using Uninstall-Module..." -ForegroundColor Yellow
            Uninstall-GraphModulesFromGallery -InstalledModules $installedGraphModules -Force:$Force
        }

        # Then remove any remaining module directories
        if ($allGraphModules.Count -gt 0) {
            Write-Host "`nRemoving remaining module directories..." -ForegroundColor Yellow
            Remove-ModuleDirectories -Modules $allGraphModules
        }

        # Force garbage collection to release any locks
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()

        Start-Sleep -Seconds 2

        $iteration++

        if ($iteration -gt $maxIterations) {
            Write-Warning "Reached maximum iterations ($maxIterations). Some modules may still remain."
            $remainingModules = Get-GraphModules
            if ($remainingModules.Count -gt 0) {
                Write-Host "`nRemaining modules:" -ForegroundColor Red
                $remainingModules | ForEach-Object { Write-Host "  - $($_.Name) ($($_.Version)) at $($_.ModuleBase)" -ForegroundColor Red }
                Write-Host "`nYou may need to manually remove these modules or restart your PowerShell session." -ForegroundColor Yellow
            }
            break
        }

    } while ($true)

    Write-Host "`n=== Cleanup Summary ===" -ForegroundColor Magenta

    # Final check
    $finalGraphModules = Get-GraphModules
    $finalInstalledModules = Get-InstalledGraphModules

    if ($finalGraphModules.Count -eq 0 -and $finalInstalledModules.Count -eq 0) {
        Write-Host "✅ All Microsoft Graph PowerShell modules have been successfully removed!" -ForegroundColor Green
        Write-Host "✅ Your system is now clean of Microsoft Graph PowerShell modules." -ForegroundColor Green
        Write-Host "💡 We recommend closing this window and starting a new PowerShell session." -ForegroundColor Green
    }
    else {
        Write-Host "⚠️  Some modules may still remain:" -ForegroundColor Yellow
        if ($finalGraphModules.Count -gt 0) {
            Write-Host "  - $($finalGraphModules.Count) modules found in module paths" -ForegroundColor Red
        }
        if ($finalInstalledModules.Count -gt 0) {
            Write-Host "  - $($finalInstalledModules.Count) installed modules from PowerShell Gallery" -ForegroundColor Red
        }
        Write-Host "  You may need to restart PowerShell and run this script again." -ForegroundColor Yellow
    }

    Write-Host "`nFunction execution completed." -ForegroundColor White
}
