﻿configuration Hubot
{   
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -Name MSFT_xRemoteFile -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName Hubot

    node $AllNodes.Where{$_.Role -eq "Hubot"}.NodeName
    {
        # Create a user to install prereqs under and run the hubot service
        User Hubot
        {
            UserName = $Node.HubotUserCreds.UserName
            Password = $Node.HubotUserCreds
            Ensure = 'Present'
            PasswordNeverExpires = $true
            PasswordChangeRequired = $false
        }
        
        # Create a user to install prereqs under and run the hubot service
        Group HubotUser
        {
            GroupName = 'Administrators'
            MembersToInclude = $Node.HubotUserCreds.UserName
            Ensure = 'Present'
            DependsOn = "[User]Hubot"
        }
        
        # Set an adapter for hubot to use
        Environment hubotadapter
        {
            Name = 'HUBOT_ADAPTER'
            Value = $Node.HubotAdapter
            Ensure = 'Present'
        }

        # Set the hubot debug level - either debug or info
        Environment hubotdebug
        {
            Name = 'HUBOT_LOG_LEVEL'
            Value = 'debug'
            Ensure = 'Present'
        }

        # Set any other environment variables that may be required for the hubot scripts
        Environment hubotslacktoken
        {
            Name = 'HUBOT_SLACK_TOKEN'
            Value = $Node.SlackAPIKey
            Ensure = 'Present'
        }

        # Install the Prereqs using the same Hubot user
        HubotPrerequisites installPreqs
        {
            PsDscRunAsCredential = $Node.HubotUserCreds
        }

        # Download the HubotWindows Repo
        xRemoteFile hubotRepo
        {
            DestinationPath = "$($env:Temp)\HubotWindows.zip"
            Uri = "https://github.com/MattHodge/HubotWindows/releases/download/0.0.2/HubotWindows-0.0.2.zip"
        }

        # Extract the Hubot Repo
        Archive extractHubotRepo
        {
            Path = "$($env:Temp)\HubotWindows.zip"
            Destination = $Node.HubotBotPath
            Ensure = 'Present'
            DependsOn = '[xRemoteFile]hubotRepo'
        }

        # Install Hubot
        HubotInstall installHubot
        {
            BotPath = $Node.HubotBotPath
            Ensure = 'Present'
            DependsOn = '[Archive]extractHubotRepo'
        }

        # Install Hubot as a service using NSSM
        HubotInstallService myhubotservice
        {
            BotPath = $Node.HubotBotPath
            ServiceName = "Hubot_$($Node.HubotBotName)"
            BotAdapter = $Node.HubotAdapter
            Ensure = 'Present'
            DependsOn = '[HubotPrerequisites]installPreqs'
            Credential = $Node.HubotUserCreds
        }
    }
}

# Create Hubot Credentials (save having to enter them every time - don't do this for production!)
$hubotUserPass = ConvertTo-SecureString 'MyPASSWORD!' -AsPlainText -Force
$hubotUserCreds = New-Object System.Management.Automation.PSCredential ('Hubot', $hubotUserPass)


$configData = @{
AllNodes = @(
        @{
            NodeName = 'localhost';
            PSDscAllowPlainTextPassword = $true
            Role = 'Hubot'
            HubotUserCreds = $hubotUserCreds
            SlackAPIKey = 'xoxb-XXXXXXXXXXXXXXXX-XXXXXXXXXXXXXXXX'
            HubotAdapter = 'slack'
            HubotBotName = 'bender'
            HubotBotPath = 'C:\myhubot'
        }
    )
}