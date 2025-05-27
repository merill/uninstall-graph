<#PSScriptInfo

.VERSION 1.0.0

.GUID 5a542c3f-51e8-44a8-be81-1f174d03fbcc

.AUTHOR Merill Fernando

.COMPANYNAME Jozra

.COPYRIGHT Copyright (c) 2025 Merill Fernando. All rights reserved.

.TAGS Microsoft Graph PowerShell Uninstall Module Cleanup

.LICENSEURI https://github.com/merill/uninstall-graph/blob/main/LICENSE

.PROJECTURI https://github.com/merill/uninstall-graph

.ICONURI

#>

<#
.SYNOPSIS
Completely uninstalls and removes all Microsoft Graph PowerShell modules from the system.

.DESCRIPTION

Microsoft Graph comes with a large number of modules and the installed versions and dependencies can sometimes cause issues when trying to update or reinstall them.

Another side effect is seeing multiple authentication prompts when using Microsoft Graph cmdlets, which can be frustrating.

Uninstalling the Microsoft Graph PowerShell modules can help resolve these issues by ensuring a clean slate.

However, the uninstallation process can be tricky because Microsoft Graph PowerShell modules
are often interdependent, making it difficult to remove them cleanly in one go using the `Uninstall-Module` cmdlet.

This script is designed to ensure that all Microsoft Graph modules are thoroughly removed from your system,
and restore your PowerShell environment to a clean state.

You can then download and do a fresh install of the latest version of Microsoft Graph PowerShell modules.


.PARAMETER Verbose
Provides detailed output during the uninstallation process.

.EXAMPLE
Uninstall-Graph

Runs the script with default settings.

.EXAMPLE

Uninstall-Graph.ps1 -SkipAdminCheck

Runs the script without checking for administrator privileges.
#>

[CmdletBinding()]
param(
    [switch]$Force,
    [switch]$SkipAdminCheck
)

# Function to check if running as administrator (Windows only)
function Test-IsAdmin {
    if ($PSVersionTable.PSVersion.Major -ge 6 -and $IsWindows -eq $false) {
        return $true  # On non-Windows systems, assume we have sufficient privileges
    }

    try {
        $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    catch {
        Write-Warning "Could not determine if running as administrator. Proceeding anyway."
        return $true
    }
}

# Function to get all Microsoft Graph modules
function Get-GraphModules {
    $graphModules = Get-Module -ListAvailable | Where-Object {
        $_.Name -like "Microsoft.Graph*" -or
        $_.Name -eq "Microsoft.Graph"
    }
    return $graphModules
}

# Function to get installed Microsoft Graph modules from PowerShell Gallery
function Get-InstalledGraphModules {
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

# Function to remove module directories
function Remove-ModuleDirectories {
    param([array]$Modules)

    foreach ($module in $Modules) {
        $modulePaths = @()

        # Get all possible module paths
        if ($module.ModuleBase) {
            $modulePaths += $module.ModuleBase
        }

        # Also check parent directories that might contain multiple versions
        $parentPath = Split-Path -Parent $module.ModuleBase -ErrorAction SilentlyContinue
        if ($parentPath -and (Split-Path -Leaf $parentPath) -eq $module.Name) {
            $modulePaths += $parentPath
        }

        foreach ($path in $modulePaths) {
            if (Test-Path $path) {
                try {
                    Write-Host "Removing module directory: $path" -ForegroundColor Yellow
                    Remove-Item -Path $path -Recurse -Force -ErrorAction Stop
                    Write-Host "Successfully removed: $path" -ForegroundColor Green
                }
                catch {
                    Write-Warning "Failed to remove directory $path : $($_.Exception.Message)"
                    # Try to remove individual files
                    try {
                        Get-ChildItem -Path $path -Recurse -Force | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                        Remove-Item -Path $path -Force -ErrorAction SilentlyContinue
                    }
                    catch {
                        Write-Warning "Could not remove $path even with force"
                    }
                }
            }
        }
    }
}

# Function to uninstall modules using Uninstall-Module
function Uninstall-GraphModulesFromGallery {
    param([array]$InstalledModules)

    foreach ($module in $InstalledModules) {
        try {
            Write-Host "Uninstalling module: $($module.Name) version $($module.Version)" -ForegroundColor Cyan

            if ($Force) {
                Uninstall-Module -Name $module.Name -RequiredVersion $module.Version -Force -ErrorAction Stop
            }
            else {
                Uninstall-Module -Name $module.Name -RequiredVersion $module.Version -ErrorAction Stop
            }

            Write-Host "Successfully uninstalled: $($module.Name)" -ForegroundColor Green
        }
        catch {
            Write-Warning "Failed to uninstall $($module.Name): $($_.Exception.Message)"

            # Try uninstalling all versions
            try {
                Write-Host "Attempting to uninstall all versions of $($module.Name)" -ForegroundColor Yellow
                if ($Force) {
                    Uninstall-Module -Name $module.Name -AllVersions -Force -ErrorAction Stop
                }
                else {
                    Uninstall-Module -Name $module.Name -AllVersions -ErrorAction Stop
                }
                Write-Host "Successfully uninstalled all versions of: $($module.Name)" -ForegroundColor Green
            }
            catch {
                Write-Warning "Failed to uninstall all versions of $($module.Name): $($_.Exception.Message)"
            }
        }
    }
}

# Main execution
Write-Host "=== Microsoft Graph PowerShell Module Uninstaller ===" -ForegroundColor Magenta
Write-Host "This script will completely remove all Microsoft Graph PowerShell modules from your system." -ForegroundColor White
Write-Host ""

# Check if running as administrator on Windows
if (-not $SkipAdminCheck -and $PSVersionTable.PSVersion.Major -lt 6 -or ($PSVersionTable.PSVersion.Major -ge 6 -and $IsWindows)) {
    if (-not (Test-IsAdmin)) {
        Write-Error "We recommend running with administrator privileges. If you are unable to run as administrator, please use the -SkipAdminCheck parameter to run without Administrator privileges."
        exit 1
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
        Uninstall-GraphModulesFromGallery -InstalledModules $installedGraphModules
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

Write-Host "`nScript execution completed." -ForegroundColor White
