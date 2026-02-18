# Uninstall-Graph PowerShell Module

Completely uninstalls and removes all Microsoft Graph, Microsoft Entra, Azure PowerShell (Az), and legacy AzureRM modules from the system.

[![PSGallery Release Version](https://img.shields.io/powershellgallery/v/uninstall-graph.svg?style=flat&logo=powershell&label=Release%20Version)](https://www.powershellgallery.com/packages/uninstall-graph) [![PSGallery Downloads](https://img.shields.io/powershellgallery/dt/uninstall-graph.svg?style=flat&logo=powershell&label=PSGallery%20Downloads)](https://www.powershellgallery.com/packages/uninstall-graph)

## Quick Reference

| Command | What it removes |
|---|---|
| `Uninstall-Graph` | Microsoft.Graph.* modules |
| `Uninstall-Graph -Entra` | Microsoft.Entra.* modules only |
| `Uninstall-Graph -All` | Microsoft.Graph.* + Microsoft.Entra.* modules |
| `Uninstall-Az` | Az.* modules + legacy AzureRM.* modules |
| `Uninstall-All` | All of the above + AIPService, MSIdentityTools, AzureAD, AzureADPreview, ExchangeOnlineManagement, MicrosoftTeams, Microsoft.Online.SharePoint.PowerShell |

All commands support the `-SkipAdminCheck` parameter to run without elevated privileges on Windows.

## Installation

To install the `Uninstall-Graph` module from PowerShell Gallery, use the following command:

```powershell
Install-Module Uninstall-Graph
```

## Uninstall Microsoft Graph

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

## Uninstall Azure PowerShell (Az)

To completely remove all Azure PowerShell (Az) modules, run:

```powershell
Uninstall-Az
```

Run without elevated permission on Windows:

```powershell
Uninstall-Az -SkipAdminCheck
```

### Parameters

- **`-SkipAdminCheck`**: Skips the administrator privileges check on Windows systems

### AzureRM support

`Uninstall-Az` automatically detects and removes legacy AzureRM modules (`AzureRM.*`, `Azure.Storage`, `Azure.AnalysisServices`). No extra command is needed — if AzureRM modules are present on the system they will be cleaned up in the same run.

If the `Uninstall-AzureRm` cmdlet from `Az.Accounts` is available on the system, it will be used first as the [recommended approach from Microsoft](https://learn.microsoft.com/en-us/powershell/azure/uninstall-az-ps?view=azps-15.3.0#option-2-uninstall-the-azurerm-powershell-module-from-powershellget). If any AzureRM modules remain after that (or if the cmdlet isn't available), the script falls back to manual module-by-module removal with directory cleanup — the same retry-based approach used for Az and Graph modules.

### Why a separate command for Az?

Azure PowerShell (Az) has a similar problem to Microsoft Graph — it ships a large number of sub-modules
(Az.Compute, Az.Storage, Az.Network, etc.) that depend on `Az.Accounts`. These interdependencies make
it difficult to cleanly remove them in one pass with `Uninstall-Module`.

`Uninstall-Az` handles this by retrying multiple times, uninstalling dependent modules first and
`Az.Accounts` last, and then cleaning up any remaining module directories from disk.

The same applies to legacy AzureRM modules where `AzureRM.Profile` is the base dependency and is removed last.

## Uninstall Everything

To remove **all** Microsoft cloud PowerShell modules (Graph, Entra, Az, and AzureRM) in one go:

```powershell
Uninstall-All
```

Run without elevated permission on Windows:

```powershell
Uninstall-All -SkipAdminCheck
```

### Parameters

- **`-SkipAdminCheck`**: Skips the administrator privileges check on Windows systems

`Uninstall-All` sequentially runs:

1. `Uninstall-Graph -All` — removes Graph + Entra modules
2. `Uninstall-Az` — removes Az + AzureRM modules
3. Removes additional Microsoft cloud modules if detected:
   - **AIPService** — Azure Information Protection
   - **MSIdentityTools** — Microsoft Identity tools
   - **AzureAD** — Azure Active Directory (legacy)
   - **AzureADPreview** — Azure AD Preview (legacy)
   - **ExchangeOnlineManagement** — Exchange Online
   - **MicrosoftTeams** — Microsoft Teams
   - **Microsoft.Online.SharePoint.PowerShell** — SharePoint Online

## Why not just use `Uninstall-Module`?

Microsoft Graph, Azure PowerShell (Az), and legacy AzureRM all come with a large number of modules and the installed versions and dependencies can sometimes cause issues when trying to update or reinstall them.

Another side effect is seeing multiple authentication prompts when using Microsoft Graph cmdlets, which can be frustrating.

Uninstalling these modules can help resolve these issues by ensuring a clean slate.

However, the uninstallation process can be tricky because these modules
are often interdependent, making it difficult to remove them cleanly in one go using the `Uninstall-Module` cmdlet.

This module handles the complexity for you by:

- **Retrying multiple times** — dependency conflicts often prevent modules from being removed on the first pass, so the script loops until everything is gone (up to 10 iterations)
- **Ordering uninstalls by dependency** — `Az.Accounts` (for Az) and `AzureRM.Profile` (for AzureRM) are removed last since other modules depend on them
- **Cleaning up leftover directories** — even after `Uninstall-Module`, module folders can remain on disk; the script removes them
- **Using Microsoft's recommended tools when available** — for AzureRM, the script tries the `Uninstall-AzureRm` cmdlet from `Az.Accounts` before falling back to manual cleanup

You can then download and do a fresh install of the latest versions.

## Reporting issues

If you run into any problems and edge cases with the module please open an issue. 

Even better, if you find a resolution feel free to open a pull request.

I'm hoping we can iron out all the edge cases over time. Thanks 🙏
