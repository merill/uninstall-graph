# Uninstall-Graph PowerShell Module

Completely uninstalls and removes all Microsoft Graph PowerShell modules from the system.

[![PSGallery Release Version](https://img.shields.io/powershellgallery/v/uninstall-graph.svg?style=flat&logo=powershell&label=Release%20Version)](https://www.powershellgallery.com/packages/uninstall-graph) [![PSGallery Downloads](https://img.shields.io/powershellgallery/dt/uninstall-graph.svg?style=flat&logo=powershell&label=PSGallery%20Downloads)](https://www.powershellgallery.com/packages/uninstall-graph)

## Installation

### From PowerShell Gallery (Recommended)

To install the `Uninstall-Graph` module from PowerShell Gallery, use the following command:

```powershell
Install-Module Uninstall-Graph
```

## Usage

To use the `Uninstall-Graph` function, simply run:

```powershell
Uninstall-Graph
```

Run without elevated permission on Windows:

```powershell
Uninstall-Graph -SkipAdminCheck
```

Uninstall only Microsoft Entra PowerShell modules (does not uninstall Microsoft Graph modules):

```powershell
Uninstall-Graph -Entra
```

Uninstall both Microsoft Graph and Microsoft Entra PowerShell modules:

```powershell
Uninstall-Graph -All
```

### Parameters

- **`-SkipAdminCheck`**: Skips the administrator privileges check on Windows systems
- **`-Entra`**: Uninstalls only Microsoft.Entra* modules (does not remove Microsoft Graph modules)
- **`-All`**: Uninstalls both Microsoft.Graph* and Microsoft.Entra* modules

## Why not just use `Uninstall-Module`?

Microsoft Graph comes with a large number of modules and the installed versions and dependencies can sometimes cause issues when trying to update or reinstall them.

Another side effect is seeing multiple authentication prompts when using Microsoft Graph cmdlets, which can be frustrating.

Uninstalling the Microsoft Graph PowerShell modules can help resolve these issues by ensuring a clean slate.

However, the uninstallation process can be tricky because Microsoft Graph PowerShell modules
are often interdependent, making it difficult to remove them cleanly in one go using the `Uninstall-Module` cmdlet.

This script is designed to ensure that all Microsoft Graph modules are thoroughly removed from your system,
and restore your PowerShell environment to a clean state.

You can then download and do a fresh install of the latest version of Microsoft Graph PowerShell modules.

## Development

### Building the Module

To build the module from source:

```powershell
./build/Build-Module.ps1 -Task Build
```

### Testing the Module

To build and test the module:

```powershell
./build/Build-Module.ps1 -Task Test
```

### Installing Locally

To build, test, and install the module to your local PowerShell modules directory:

```powershell
./build/Build-Module.ps1 -Task Install
```

### Publishing to PowerShell Gallery

To build, test, and publish the module to PowerShell Gallery:

```powershell
$apiKey = Read-Host -AsSecureString -Prompt "Enter your PSGallery API Key"
./build/Build-Module.ps1 -Task Publish -ApiKey $apiKey
```

You can also specify a different repository:

```powershell
$apiKey = Read-Host -AsSecureString -Prompt "Enter your API Key"
./build/Build-Module.ps1 -Task Publish -ApiKey $apiKey -Repository "MyPrivateRepo"
```

### Cleaning Build Artifacts

To remove the build output directory:

```powershell
./build/Build-Module.ps1 -Task Clean
```

## Reporting issues

If you run into any problems and edge cases with the module please open an issue. 

Even better, if you find a resolution feel free to open a pull request.

I'm hoping we can iron out all the edge cases over time. Thanks 🙏
