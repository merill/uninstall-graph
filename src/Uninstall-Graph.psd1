@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'Uninstall-Graph.psm1'

    # Version number of this module.
    ModuleVersion = '1.4.0'

    # Supported PSEditions
    CompatiblePSEditions = @('Desktop', 'Core')

    # ID used to uniquely identify this module
    GUID = 'd964b8b7-7ef9-43ee-b5cb-6d95ec7b0dcd'

    # Author of this module
    Author = 'Merill Fernando'

    # Company or vendor of this module
    CompanyName = 'Jozra'

    # Copyright statement for this module
    Copyright = 'Copyright (c) 2025 Merill Fernando. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'Completely uninstalls and removes all Microsoft Graph PowerShell modules from the system. Microsoft Graph comes with a large number of modules and the installed versions and dependencies can sometimes cause issues when trying to update or reinstall them. This module ensures that all Microsoft Graph modules are thoroughly removed from your system, and restore your PowerShell environment to a clean state.'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @('Uninstall-Graph')

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('Microsoft', 'Graph', 'PowerShell', 'Uninstall', 'Module', 'Cleanup')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/merill/uninstall-graph/blob/main/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/merill/uninstall-graph'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            ReleaseNotes = 'Initial release - Completely uninstalls and removes all Microsoft Graph PowerShell modules from the system.'

            # Prerelease string of this module
            # Prerelease = ''

            # Flag to indicate whether the module requires explicit user acceptance for install/update/save
            # RequireLicenseAcceptance = $false

            # External dependent modules of this module
            # ExternalModuleDependencies = @()
        }
    }

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''
}
