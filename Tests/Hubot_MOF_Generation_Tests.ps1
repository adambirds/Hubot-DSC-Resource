describe "Hubot DSC Module - MOF Testing" {

    $dscExamplePath = Join-path -Path '.\DSCConfigurations' -ChildPath 'dsc_configuration.ps1'

    context "Get-DSCResource" {
        $res = Get-DscResource
        
        it "returns something" {
            $res | Should Not Be Null
        }

        $hubotRes = @(
            'HubotInstall'
            'HubotInstallService'
            'HubotPrerequisites'
        )

        ForEach ($h in $hubotRes)
        {
            it "contains resource $($h)" {
                $res.Name -contains $h | Should Be $true
            }
        }
    }

    context "Example dsc_configuration" {
        it "is valid powershell" {
            $psfile = Get-Content -Path $dscExamplePath -Raw -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($psfile, [ref]$errors)
            $errors.Count | Should Be 0
        }

        . $dscExamplePath

        it "module version of InstallHubot.psd1 matches module version in $dscExamplePath" {
            $moduleVersion = Select-String -Path .\InstallHubot\InstallHubot.psd1 -Pattern "ModuleVersion = '(.*)'"
            $moduleVersion = $moduleVersion.Matches.Groups[1].Value

            $exampleVersion = Select-String -Path $dscExamplePath -Pattern 'ModuleName=\"InstallHubot\"\; RequiredVersion=\"(.*)\"'
            $exampleVersion = $exampleVersion.Matches.Groups[1].Value

            $exampleVersion | Should BeExactly $moduleVersion
        }

        it "does not have a real api key" {
            $configData.AllNodes.SlackAPIKey | Should Be 'xoxb-XXXXXXXXXXXXXXXX-XXXXXXXXXXXXXXXX'
        }

        it "does not throw on mof generation" {
            { Hubot -OutputPath TestDrive:\mof -ConfigurationData $configData } | Should Not Throw
        }

        it "mof file is created on disk" {
            Test-Path -Path "TestDrive:\mof\localhost.mof" | Should Be $true
        }
    }
}
