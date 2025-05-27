function Remove-ModuleDirectories {
    <#
    .SYNOPSIS
    Removes module directories from the file system.

    .DESCRIPTION
    This function removes the physical directories containing Microsoft Graph module files.

    .PARAMETER Modules
    Array of module objects whose directories should be removed.
    #>

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
                    Write-Host "> $path" -ForegroundColor Yellow
                    Remove-Item -Path $path -Recurse -Force -ErrorAction Stop
                    Write-Host " ✅ Removed" -ForegroundColor Green
                }
                catch {
                    Write-Verbose " Failed to remove directory $path : $($_.Exception.Message)"
                    # Try to remove individual files
                    try {
                        Get-ChildItem -Path $path -Recurse -Force | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                        Remove-Item -Path $path -Force -ErrorAction SilentlyContinue
                    }
                    catch {
                        Write-Warning " 🔺 Could not remove even with force."
                    }
                }
            }
        }
    }
}
