Configuration Hubot {   
    Param (
		[Parameter(Mandatory=$true)]
		[string]$NodeName,
		[Parameter(Mandatory=$true)]
		[string]$Role,
		[Parameter(Mandatory=$true)]
		[string]$SlackAPIKey,
		[Parameter(Mandatory=$true)]
		[string]$HubotAdapter,
		[Parameter(Mandatory=$true)]
		[string]$HubotBotName,
		[Parameter(Mandatory=$true)]
		[string]$HubotBotPath
	)

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -Name MSFT_xRemoteFile -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName @{ModuleName="Hubot"; RequiredVersion="1.2.0"}

             
        # Set an adapter for hubot to use
        Environment hubotadapter {
            Name = 'HUBOT_ADAPTER'
            Value = $HubotAdapter
            Ensure = 'Present'
        }

        # Set the hubot debug level - either debug or info
        Environment hubotdebug {
            Name = 'HUBOT_LOG_LEVEL'
            Value = 'debug'
            Ensure = 'Present'
        }

        # Set any other environment variables that may be required for the hubot scripts
        Environment hubotslacktoken {
            Name = 'HUBOT_SLACK_TOKEN'
            Value = $SlackAPIKey
            Ensure = 'Present'
        }

        # Install the Prereqs using the same Hubot user
        HubotPrerequisites installPreqs {
            Ensure = 'Present'
        }

        # Download the HubotWindows Repo
        xRemoteFile hubotRepo {
            DestinationPath = "$($env:Temp)\HubotWindows.zip"
            Uri = "https://github.com/MattHodge/HubotWindows/releases/download/0.0.2/HubotWindows-0.0.2.zip"
        }

        # Extract the Hubot Repo
        Archive extractHubotRepo {
            Path = "$($env:Temp)\HubotWindows.zip"
            Destination = $HubotBotPath
            Ensure = 'Present'
            DependsOn = '[xRemoteFile]hubotRepo'
        }

        # Install Hubot
        HubotInstall installHubot {
            BotPath = $HubotBotPath
            Ensure = 'Present'
            DependsOn = '[Archive]extractHubotRepo','[HubotPrerequisites]installPreqs'
        }
        
        # Install Hubot as a service using NSSM
        HubotInstallService myhubotservice {
            BotPath = $HubotBotPath
            ServiceName = "Hubot_$($HubotBotName)"
            BotAdapter = $HubotAdapter
            Ensure = 'Present'
            DependsOn = '[HubotInstall]installHubot','[HubotPrerequisites]installPreqs'
        }
    }
}