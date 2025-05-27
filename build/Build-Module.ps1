# Build script for Uninstall-Graph PowerShell Module

param(
    [ValidateSet('Build', 'Test', 'Publish', 'Install', 'Clean')]
    [string]$Task = 'Build',

    [string]$OutputPath = './release/Uninstall-Graph',

    [string]$Repository = 'PSGallery',

    [string]$ApiKey
)

# Clean output directory
function Invoke-Clean {
    if (Test-Path $OutputPath) {
        Remove-Item -Path $OutputPath -Recurse -Force
        Write-Host "Cleaned output directory: $OutputPath" -ForegroundColor Green
    }
}

# Build the module
function Invoke-Build {
    Write-Host "Building Uninstall-Graph module..." -ForegroundColor Cyan

    # Clean first
    Invoke-Clean

    # Create output directory
    New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null

    # Copy module files
    Copy-Item -Path "./src/Uninstall-Graph.psd1" -Destination $OutputPath
    Copy-Item -Path "./src/Uninstall-Graph.psm1" -Destination $OutputPath

    # Copy Private and Public function folders
    if (Test-Path "./src/Private") {
        Copy-Item -Path "./src/Private" -Destination $OutputPath -Recurse
        Write-Host "Copied Private functions" -ForegroundColor Yellow
    }

    if (Test-Path "./src/Public") {
        Copy-Item -Path "./src/Public" -Destination $OutputPath -Recurse
        Write-Host "Copied Public functions" -ForegroundColor Yellow
    }

    # Copy license and readme to module directory
    if (Test-Path "./LICENSE") {
        Copy-Item -Path "./LICENSE" -Destination $OutputPath
    }

    if (Test-Path "./README.md") {
        Copy-Item -Path "./README.md" -Destination $OutputPath
    }

    Write-Host "Module built successfully in: $OutputPath" -ForegroundColor Green
}

# Test the module
function Invoke-Test {
    Write-Host "Testing Uninstall-Graph module..." -ForegroundColor Cyan

    # Import the module
    Import-Module "$OutputPath/Uninstall-Graph.psd1" -Force

    # Test if the function is available
    $command = Get-Command Uninstall-Graph -ErrorAction SilentlyContinue
    if ($command) {
        Write-Host "✅ Uninstall-Graph function is available" -ForegroundColor Green

        # Display help
        Write-Host "`nFunction help:" -ForegroundColor Yellow
        Get-Help Uninstall-Graph -Detailed
    } else {
        Write-Error "❌ Uninstall-Graph function not found"
        return $false
    }

    # Test module manifest
    $manifest = Test-ModuleManifest "$OutputPath/Uninstall-Graph.psd1"
    if ($manifest) {
        Write-Host "✅ Module manifest is valid" -ForegroundColor Green
        Write-Host "   Version: $($manifest.Version)" -ForegroundColor White
        Write-Host "   Author: $($manifest.Author)" -ForegroundColor White
        Write-Host "   Description: $($manifest.Description)" -ForegroundColor White
    } else {
        Write-Error "❌ Module manifest validation failed"
        return $false
    }

    Write-Host "✅ All tests passed!" -ForegroundColor Green
    return $true
}

# Install the module locally
function Invoke-Install {
    Write-Host "Installing Uninstall-Graph module locally..." -ForegroundColor Cyan

    # Get user module path
    $userModulePath = $env:PSModulePath.Split([IO.Path]::PathSeparator) |
        Where-Object { $_ -like "*$env:USERNAME*" -or $_ -like "*Users*" } |
        Select-Object -First 1

    if (-not $userModulePath) {
        $userModulePath = "$env:USERPROFILE\Documents\PowerShell\Modules"
    }

    $installPath = Join-Path $userModulePath "Uninstall-Graph"

    # Remove existing installation
    if (Test-Path $installPath) {
        Remove-Item -Path $installPath -Recurse -Force
        Write-Host "Removed existing installation" -ForegroundColor Yellow
    }

    # Create directory and copy files
    New-Item -Path $installPath -ItemType Directory -Force | Out-Null
    Copy-Item -Path "$OutputPath/*" -Destination $installPath -Recurse

    Write-Host "Module installed to: $installPath" -ForegroundColor Green
    Write-Host "You can now use: Import-Module Uninstall-Graph" -ForegroundColor Cyan
}

# Publish the module
function Invoke-Publish {
    if (-not $ApiKey) {
        Write-Error "API Key is required for publishing. Use -ApiKey parameter."
        return
    }

    Write-Host "Publishing Uninstall-Graph module to $Repository..." -ForegroundColor Cyan

    try {
        Publish-Module -Path $OutputPath -Repository $Repository -NuGetApiKey $ApiKey
        Write-Host "✅ Module published successfully!" -ForegroundColor Green
    }
    catch {
        Write-Error "❌ Failed to publish module: $($_.Exception.Message)"
    }
}

# Main execution
switch ($Task) {
    'Build' { Invoke-Build }
    'Test' {
        Invoke-Build
        Invoke-Test
    }
    'Publish' {
        Invoke-Build
        if (Invoke-Test) {
            Invoke-Publish
        }
    }
    'Install' {
        Invoke-Build
        if (Invoke-Test) {
            Invoke-Install
        }
    }
    'Clean' { Invoke-Clean }
}
