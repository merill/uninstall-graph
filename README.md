# Uninstall Graph

Completely uninstalls and removes all Microsoft Graph PowerShell modules from the system.

## Installation

To install the `Uninstall-Graph` script, you can use the following PowerShell command:

```powershell
Install-Script -Name Uninstall-Graph
```

## Usage

To use the `Uninstall-Graph` script, simply run the following command in your PowerShell session:

```powershell
Uninstall-Graph
```

To run without elevated permision on Windows, you can use the`-SkipAdminCheck` parameter:

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
