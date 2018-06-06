# Hubot (DSC Resource)

![Hubot](http://i.imgur.com/NhTqeZ2.png)

[![Build status](https://ci.appveyor.com/api/projects/status/yj30jkt66cy2ihix/branch/master?svg=true)](https://ci.appveyor.com/project/adambirds/hubot-dsc-resource/branch/master)

The **InstallHubot** module contains the `HubotPrerequisites`, `HubotInstall` and `HubotInstallService`
DSC Resources to install Hubot on Windows with Slack as the adapter.

This resource installs and runs Hubot as a service on Windows using NSSM.

## DSC Configuration

You can find the DSC Configuration here: [dsc_configuration.ps1](DSCConfigurations/dsc_configuration.ps1)

## Installation

1. To install the module, use:

   `Install-Module -Name InstallHubot`

2. To setup the DSC Configuartion, run the [dsc_configuration.ps1](DSCConfigurations/dsc_configuration.ps1) script.

3. To create your MOF file run the below commands, editing the variables to what you need:

   ``` powershell
   cd "C:\SCRIPTS" #Make this diretcory if not already existing
   Hubot -NodeName "localhost" -SlackAPIKey "xoxb-YOUR-TOKEN-HERE" -HubotAdapter "slack" -HubotBotName "bot" -HubotBotPath "C:\SCRIPTS\myhubot" #HubotBotName can not be Hubot
   ```

4. To run the DSC Configuration run the following commands:

   ```powershell
   Start-DSCConfiguration -Path "C:\SCRIPTS\Hubot" -Wait
   ```

   The server will then ask for a reboot. Reboot the server and again run the below command:

   ``` powershell
   Start-DSCConfiguration -Path "C:\SCRIPTS\Hubot" -Wait
   ```

## Packaging

The DSC Resource Module is called `InstallHubot` and is available on the PowerShell Gallery:
* https://www.powershellgallery.com/packages/InstallHubot

## Versions

### 1.2.0

* Updated module dependencies so that it pulls down later versions of Git and NodeJs
* Updated module dependences so that it installs `MSFT_xScriptResource` as part of `xPSDesiredStateConfiguration`
* Updated DSC Configuration to fix several bugs.
* Updated Documentation

### 1.1.5

* Updated module dependencies so it pulls down `xPSDesiredStateConfiguration` on install.

### 1.1.4

* Removing dependency on `cChoco` and `Chocolatey`. This requires the node to reboot after installing Node.js as part of the `HubotPrerequisites` resource unfortunately.


### 1.1.3

* Initial Release
