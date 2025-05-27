# Publishing this script

## Increment the version number

Increment the .VERSION parameter in the Uninstall-Graph.ps1 script to the new version number.

## Publish to the PowerShell gallery

To publish the script to the PowerShell gallery, run the following command from the root.

```powershell
$key = Read-Host -Prompt 'Enter your API key' -AsSecureString
$nugetKey = ConvertFrom-SecureString $key -AsPlainText
Publish-Script -Path ./src/Uninstall-Graph.ps1 -NuGetApiKey $nugetKey
```
