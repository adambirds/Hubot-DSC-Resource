#
# Module manifest for module 'Hubot'
#
# Generated by: Matthew Hodgkins
#
# Generated on: 21/05/2016
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'Hubot.psm1'

# Version number of this module.
ModuleVersion = '1.1.4'

# ID used to uniquely identify this module
GUID = 'e12d6cd9-83d5-4e43-9383-9371f941d587'

# Author of this module
Author = 'Matthew Hodgkins'

# Company or vendor of this module
CompanyName = 'hodgkins.io'

# Copyright statement for this module
Copyright = '(c) 2016 Matthew Hodgkins. All rights reserved.'

# Description of the functionality provided by this module
Description = 'DSC Resource to Install Hubot on Windows'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.0'

# Minimum version of the common language runtime (CLR) required by this module
CLRVersion = '4.0'

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = ''

# DSC resources to export from this module
DscResourcesToExport = @('HubotInstall','HubotInstallService')

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('DesiredStateConfiguration', 'DSC', 'Hubot', 'DSCResource', 'ChatOps')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/MattHodge/Hubot-DSC-Resource/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/MattHodge/Hubot-DSC-Resource'

            # A URL to an icon representing this module.
            IconUri = 'http://i.imgur.com/pGGMJtb.png'

            # ReleaseNotes of this module
            # ReleaseNotes = ''

        } # End of PSData hashtable
    } # End of PrivateData hashtable
}

