<#
    .SYNOPSIS
    Completely uninstalls and removes all Microsoft cloud PowerShell modules from the system.

    .DESCRIPTION
    This function provides a single command to clean up all Microsoft cloud PowerShell modules from your system.
    It sequentially removes:
    - Microsoft Graph PowerShell modules (Microsoft.Graph.*)
    - Microsoft Entra PowerShell modules (Microsoft.Entra.*)
    - Azure PowerShell (Az) modules (Az.*)
    - Legacy AzureRM modules (AzureRM.*, Azure.Storage, Azure.AnalysisServices)
    - Additional Microsoft cloud modules: AIPService, MSIdentityTools, AzureAD,
      AzureADPreview, ExchangeOnlineManagement, MicrosoftTeams,
      Microsoft.Online.SharePoint.PowerShell

    This is useful when you want a completely clean slate for all Microsoft cloud PowerShell modules.

    .PARAMETER SkipAdminCheck
    Skips the administrator privileges check on Windows systems.

    .EXAMPLE
    Uninstall-All

    Removes all Microsoft cloud PowerShell modules from the system.

    .EXAMPLE
    Uninstall-All -SkipAdminCheck

    Removes all modules without checking for administrator privileges.
#>
function Uninstall-All {
    [CmdletBinding()]
    param(
        [switch]$SkipAdminCheck
    )

    Write-Host "=== Microsoft Cloud PowerShell Module Uninstaller ===" -ForegroundColor Cyan
    Write-Host "This cmdlet will completely remove the following modules from your system:" -ForegroundColor White
    Write-Host "  - Microsoft Graph PowerShell (Microsoft.Graph.*)" -ForegroundColor White
    Write-Host "  - Microsoft Entra PowerShell (Microsoft.Entra.*)" -ForegroundColor White
    Write-Host "  - Azure PowerShell Az (Az.*)" -ForegroundColor White
    Write-Host "  - Legacy AzureRM (AzureRM.*, Azure.Storage, Azure.AnalysisServices)" -ForegroundColor White
    Write-Host "  - AIPService, MSIdentityTools, AzureAD, AzureADPreview" -ForegroundColor White
    Write-Host "  - ExchangeOnlineManagement, MicrosoftTeams" -ForegroundColor White
    Write-Host "  - Microsoft.Online.SharePoint.PowerShell" -ForegroundColor White
    Write-Host ""
    Write-Host "If you run into issues, try running with -Verbose for more info." -ForegroundColor White
    Write-Host ""

    # Check if running as administrator on Windows (once for everything)
    if (-not $SkipAdminCheck -and ($PSVersionTable.PSVersion.Major -lt 6 -or ($PSVersionTable.PSVersion.Major -ge 6 -and $IsWindows))) {
        if (-not (Test-IsAdmin)) {
            Write-Error "We recommend running with administrator privileges. If you are unable to run as administrator, please use the -SkipAdminCheck parameter to run without Administrator privileges."
            return
        }
    }

    # Phase 1: Microsoft Graph + Entra
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host "Phase 1: Microsoft Graph & Entra modules" -ForegroundColor Magenta
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host ""
    Uninstall-Graph -All -SkipAdminCheck

    Write-Host ""

    # Phase 2: Azure PowerShell (Az + AzureRM)
    Write-Host "==========================================" -ForegroundColor Magenta
    Write-Host "Phase 2: Azure PowerShell (Az & AzureRM)" -ForegroundColor Magenta
    Write-Host "==========================================" -ForegroundColor Magenta
    Write-Host ""
    Uninstall-Az -SkipAdminCheck

    Write-Host ""

    # Phase 3: Additional Microsoft cloud modules
    $standaloneModuleNames = @(
        'AIPService'
        'MSIdentityTools'
        'AzureAD'
        'AzureADPreview'
        'ExchangeOnlineManagement'
        'MicrosoftTeams'
        'Microsoft.Online.SharePoint.PowerShell'
    )

    $standaloneFound = Get-Module -ListAvailable | Where-Object { $_.Name -in $standaloneModuleNames }
    $standaloneInstalled = @()
    try { $standaloneInstalled = Get-InstalledModule | Where-Object { $_.Name -in $standaloneModuleNames } } catch {}

    if ($standaloneFound.Count -gt 0 -or $standaloneInstalled.Count -gt 0) {
        Write-Host "================================================" -ForegroundColor Magenta
        Write-Host "Phase 3: Additional Microsoft cloud modules" -ForegroundColor Magenta
        Write-Host "================================================" -ForegroundColor Magenta
        Write-Host ""

        $detectedNames = @($standaloneFound | Select-Object -ExpandProperty Name -Unique) + @($standaloneInstalled | Select-Object -ExpandProperty Name -Unique) | Sort-Object -Unique
        Write-Host "Detected: $($detectedNames -join ', ')" -ForegroundColor White
        Write-Host ""

        Uninstall-StandaloneModules -ModuleNames $standaloneModuleNames
    }
    else {
        Write-Host "No additional Microsoft cloud modules detected. Skipping Phase 3." -ForegroundColor DarkGray
    }

    # Overall summary
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Magenta
    Write-Host "=== Overall Cleanup Summary ===" -ForegroundColor Magenta
    Write-Host "============================================" -ForegroundColor Magenta

    $graphRemaining = Get-GraphModules -IncludeGraph -IncludeEntra
    $graphInstalledRemaining = Get-InstalledGraphModules -IncludeGraph -IncludeEntra
    $azRemaining = Get-AzModules
    $azInstalledRemaining = Get-InstalledAzModules
    $azureRMRemaining = Get-AzureRMModules
    $azureRMInstalledRemaining = Get-InstalledAzureRMModules
    $standaloneRemaining = Get-Module -ListAvailable | Where-Object { $_.Name -in $standaloneModuleNames }
    $standaloneInstalledRemaining = @()
    try { $standaloneInstalledRemaining = Get-InstalledModule | Where-Object { $_.Name -in $standaloneModuleNames } } catch {}

    $allClean = (
        $graphRemaining.Count -eq 0 -and $graphInstalledRemaining.Count -eq 0 -and
        $azRemaining.Count -eq 0 -and $azInstalledRemaining.Count -eq 0 -and
        $azureRMRemaining.Count -eq 0 -and $azureRMInstalledRemaining.Count -eq 0 -and
        $standaloneRemaining.Count -eq 0 -and $standaloneInstalledRemaining.Count -eq 0
    )

    if ($allClean) {
        Write-ColorOutput "[*] All Microsoft cloud PowerShell modules have been successfully removed!" -ForegroundColor Green
        Write-ColorOutput "[*] Your system is now clean." -ForegroundColor Green
        Write-ColorOutput "[>] We recommend closing this window and starting a new PowerShell session." -ForegroundColor Green
    }
    else {
        Write-ColorOutput "[!] Some modules may still remain:" -ForegroundColor Yellow
        if ($graphRemaining.Count -gt 0 -or $graphInstalledRemaining.Count -gt 0) {
            Write-Host "  - Graph/Entra: $($graphRemaining.Count) in module paths, $($graphInstalledRemaining.Count) from Gallery" -ForegroundColor Red
        }
        if ($azRemaining.Count -gt 0 -or $azInstalledRemaining.Count -gt 0) {
            Write-Host "  - Az: $($azRemaining.Count) in module paths, $($azInstalledRemaining.Count) from Gallery" -ForegroundColor Red
        }
        if ($azureRMRemaining.Count -gt 0 -or $azureRMInstalledRemaining.Count -gt 0) {
            Write-Host "  - AzureRM: $($azureRMRemaining.Count) in module paths, $($azureRMInstalledRemaining.Count) from Gallery" -ForegroundColor Red
        }
        if ($standaloneRemaining.Count -gt 0 -or $standaloneInstalledRemaining.Count -gt 0) {
            $remainingNames = @($standaloneRemaining | Select-Object -ExpandProperty Name -Unique) + @($standaloneInstalledRemaining | Select-Object -ExpandProperty Name -Unique) | Sort-Object -Unique
            Write-Host "  - Other: $($remainingNames -join ', ')" -ForegroundColor Red
        }
        Write-Host "  You may need to restart PowerShell and run this script again." -ForegroundColor Yellow
    }
}
