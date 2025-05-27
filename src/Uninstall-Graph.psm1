#Requires -Version 5.1

<#
.SYNOPSIS
    Uninstall-Graph PowerShell Module
.DESCRIPTION
    This module provides functionality to completely uninstall and remove all Microsoft Graph PowerShell modules from the system.
.NOTES
    Author: Merill Fernando
    Company: Jozra
    Copyright: Copyright (c) 2025 Merill Fernando. All rights reserved.
#>

# Get the module root path
$ModuleRoot = $PSScriptRoot

# Load private functions
$PrivateFunctions = Get-ChildItem -Path "$ModuleRoot\Private\*.ps1" -ErrorAction SilentlyContinue
foreach ($Function in $PrivateFunctions) {
    try {
        . $Function.FullName
        Write-Verbose "Loaded private function: $($Function.BaseName)"
    }
    catch {
        Write-Error "Failed to load private function $($Function.BaseName): $($_.Exception.Message)"
    }
}

# Load public functions
$PublicFunctions = Get-ChildItem -Path "$ModuleRoot\Public\*.ps1" -ErrorAction SilentlyContinue
$ExportedFunctions = @()

foreach ($Function in $PublicFunctions) {
    try {
        . $Function.FullName
        $ExportedFunctions += $Function.BaseName
        Write-Verbose "Loaded public function: $($Function.BaseName)"
    }
    catch {
        Write-Error "Failed to load public function $($Function.BaseName): $($_.Exception.Message)"
    }
}

# Export public functions
if ($ExportedFunctions.Count -gt 0) {
    Export-ModuleMember -Function $ExportedFunctions
    Write-Verbose "Exported functions: $($ExportedFunctions -join ', ')"
} else {
    Write-Warning "No public functions found to export"
}