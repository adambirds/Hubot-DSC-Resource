@{

# Script module or binary module file associated with this manifest.
RootModule = 'HubotPrerequisites.schema.psm1'

# Version number of this module.
ModuleVersion = '2.0.0'

# ID used to uniquely identify this module
GUID = 'c4d585f6-98f0-4565-884c-312d1214aa8e'

# Author of this module
Author = 'Adam Birds'

# Company or vendor of this module
CompanyName = 'Adam Birds'

# Copyright statement for this module
Copyright = '(c) 2018 Adam Birds. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Composite DSC Resource to Install Hubot Prerequisites using cChoco'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.0'

# Minimum version of the common language runtime (CLR) required by this module
CLRVersion = '4.0'

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @()

# DSC resources to export from this module
DscResourcesToExport = 'HubotPrerequisites'

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('DesiredStateConfiguration', 'DSC', 'Hubot', 'DSCResource', 'ChatOps')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/adambirds/Hubot-DSC-Resource/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/adambirds/Hubot-DSC-Resource'

            # A URL to an icon representing this module.
            IconUri = 'http://i.imgur.com/pGGMJtb.png'

            # ReleaseNotes of this module
            # ReleaseNotes = ''

        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
