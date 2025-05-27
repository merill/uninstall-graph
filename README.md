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

## Why not just use `Uninstall-Module`?

Microsoft Graph comes with a large number of modules and the installed versions and dependencies can sometimes cause issues when trying to update or reinstall them.

Another side effect is seeing multiple authentication prompts when using Microsoft Graph cmdlets, which can be frustrating.

Uninstalling the Microsoft Graph PowerShell modules can help resolve these issues by ensuring a clean slate.

However, the uninstallation process can be tricky because Microsoft Graph PowerShell modules
are often interdependent, making it difficult to remove them cleanly in one go using the `Uninstall-Module` cmdlet.

This script is designed to ensure that all Microsoft Graph modules are thoroughly removed from your system,
and restore your PowerShell environment to a clean state.

You can then download and do a fresh install of the latest version of Microsoft Graph PowerShell modules.
