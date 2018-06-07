properties {
    # $unitTests = "$PSScriptRoot\Tests\unit"
    $unitTests = Get-ChildItem .\Tests\*Unit_Tests.ps1
    $mofTests = Get-ChildItem .\Tests\*MOF_Generation_Tests.ps1
    $DSCResources = Get-ChildItem *.psd1,*.psm1 -Recurse

    # originalPath is the one containing the .psm1 and .psd1
    $originalPath = $PSScriptRoot

    # pathInModuleDir is the path where the symbolic link will be created which points to your repo
    $pathInModuleDir = 'C:\Program Files\WindowsPowerShell\Modules\InstallHubot'

	$ProjectRoot = $ENV:BHProjectPath
        if(-not $ProjectRoot)
        {
            $ProjectRoot = Resolve-Path "$PSScriptRoot\.."
        }
}

task default -depends Analyze, Test, MOFTestDeploy, MOFTest, BuildArtifact, Deploy

task TestProperties { 
  Assert ($build_version -ne $null) "build_version should not be null"
}

task Analyze {
    ForEach ($resource in $DSCResources)
    {      
        try
        {
            Write-Output "Running ScriptAnalyzer on $($resource)"

            if ($env:APPVEYOR)
            {
                Add-AppveyorTest -Name "PsScriptAnalyzer" -Outcome Running
                $timer = [System.Diagnostics.Stopwatch]::StartNew()
            }

            $saResults = Invoke-ScriptAnalyzer -Path $resource.FullName -Verbose:$false
            if ($saResults) {
                $saResults | Format-Table
                $saResultsString = $saResults | Out-String
                if ($saResults.Severity -contains 'Error' -or $saResults.Severity -contains 'Warning')
                {
                    if ($env:APPVEYOR)
                    {
                        Add-AppveyorMessage -Message "PSScriptAnalyzer output contained one or more result(s) with 'Error or Warning' severity.`
                        Check the 'Tests' tab of this build for more details." -Category Error
                        Update-AppveyorTest -Name "PsScriptAnalyzer" -Outcome Failed -ErrorMessage $saResultsString                  
                    }               

                    Write-Error -Message "One or more Script Analyzer errors/warnings where found in $($resource). Build cannot continue!"  
                }
                else
                {
                    Write-Output "All ScriptAnalyzer tests passed"

                    if ($env:APPVEYOR)
                    {
                        Update-AppveyorTest -Name "PsScriptAnalyzer" -Outcome Passed -StdOut $saResultsString -Duration $timer.ElapsedMilliseconds
                    }
                }
            }
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Write-Output $ErrorMessage
            Write-Output $FailedItem
            Write-Error "The build failed when working with $($resource)."
        }

    } 
}

task Test {
    ForEach ($unitTest in $unitTests)
    {
        $testResults = .\Tests\appveyor.pester.ps1 -Test -TestPath $unitTest

        if ($testResults.FailedCount -gt 0) {
            $testResults | Format-List
            Write-Error -Message 'One or more Pester unit tests failed. Build cannot continue!'
        }
    }
}

task MOFTestDeploy -depends Analyze, Test {
    try
    {
        if ($env:APPVEYOR)
        {
            # copy into the userprofile in appveyor so the module can be loaded
            Start-Process -FilePath 'robocopy.exe' -ArgumentList "$PSScriptRoot $env:USERPROFILE\Documents\WindowsPowerShell\Modules\InstallHubot /S /R:1 /W:1" -Wait -NoNewWindow
        }
        else
        {
            # on a local system just create a symlink
            New-Item -ItemType SymbolicLink -Path $pathInModuleDir -Target $originalPath -Force | Out-Null
        }
    }
    catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Output $ErrorMessage
        Write-Output $FailedItem
        throw "The build failed when trying prepare files for MOF tests."
    }
}

task MOFTest -depends Analyze, Test, MOFTestDeploy {
    ForEach ($moftest in $mofTests)
    {
        $testResults = .\Tests\appveyor.pester.ps1 -Test -TestPath $moftest
        if ($testResults.FailedCount -gt 0) {
            $testResults | Format-List
            Write-Error -Message 'One or more Pester unit tests failed. Build cannot continue!'
        }
    }
}

task BuildArtifact -depends Analyze, Test, MOFTestDeploy, MOFTest {
    # Create a clean to build the artifact
    New-Item -Path "$PSScriptRoot\Artifact" -ItemType Directory -Force

    # Copy the correct items into the artifacts directory, filtering out the junk
    Start-Process -FilePath 'robocopy.exe' -ArgumentList "`"$($PSScriptRoot)`" `"$($PSScriptRoot)\Artifact\InstallHubot`" /S /R:1 /W:1 /XD Artifact .kitchen .git /XF .gitignore build.ps1 psakeBuild.ps1 *.yml *.xml" -Wait -NoNewWindow

    # Create a zip file artifact
    Compress-Archive -Path $PSScriptRoot\Artifact\InstallHubot -DestinationPath $PSScriptRoot\Artifact\InstallHubot-$build_version.zip -Force

    if ($env:APPVEYOR)
    {
        # Push the artifact into appveyor
        $zip = Get-ChildItem -Path $PSScriptRoot\Artifact\*.zip |  ForEach-Object { Push-AppveyorArtifact $_.FullName -FileName $_.Name }
    }
}

task Deploy -depends BuildArtifact {
    Try {
        #Create the new version value and the dsc resource list.
        $ManifestPath = "$PSScriptRoot\InstallHubot\InstallHubot.psd1"
        $Manifest = Test-ModuleManifest -Path $ManifestPath
        [System.Version]$version = $Manifest.Version
        [System.Version]$oldversion = $Manifest.Version
        Write-Output "Old Version: $version"
        [String]$newVersion = New-Object -TypeName System.Version -ArgumentList ($version.Major, $version.Minor, ($version.Build+1))
        If ($newVersion -ne $env:appveyor_build_version) {
            $newVersion = $env:appveyor_build_version
            Write-Output "New Version: $newVersion"
        } Else {
            Write-Output "New Version: $newVersion"
        }
        $env:newVersion = $newVersion
        $DscResources = $Manifest.ExportedDscResources
        $NoOfDscResources = $DscResources.Count
        $Count = 0
        ForEach ($DscResource in $DscResources) {
            $Count = $Count + 1
            If ($Count -eq 1 -and $Count -eq $NoOfDscResources) {
                $DscResourceList = "@('$DscResource')"
            } ElseIf ($Count -eq 1 -and $Count -ne $NoOfDscResources) {
                $DscResourceList = "@('$DscResource'"
            } ElseIf ($Count -eq $NoOfDscResources) {
                $DscResourceList = $DscResourceList + ", '$DscResource')"
            } Else {
                $DscResourceList = $DscResourceList + ", '$DscResource'"
            }
        }
        #Updates the module with the new version and fixes string replace bug.
        Update-ModuleManifest -Path $manifestPath -ModuleVersion $newVersion -DscResourcesToExport $DscResources
        (Get-Content -Path "$PSScriptRoot\DSCConfigurations\dsc_configuration.ps1") -replace $oldversion, $newversion | Set-Content -Path "$PSScriptRoot\DSCConfigurations\dsc_configuration.ps1" -Force
        (Get-Content -Path $manifestPath) -replace 'PSGet_InstallHubot', 'InstallHubot' | Set-Content -Path $ManifestPath
        (Get-Content -Path $manifestPath) -replace 'NewManifest', 'InstallHubot' | Set-Content -Path $ManifestPath
        $Line = Get-Content $ManifestPath | Select-String "DscResourcesToExport =" | Select-Object -ExpandProperty Line
        (Get-Content -Path $manifestPath) -replace $Line, "DscResourcesToExport = $DscResourceList" | Set-Content -Path $ManifestPath -Force
    } Catch {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Output $ErrorMessage
        Write-Output $FailedItem
        throw "Incrementing version failed. Build can not continue."
    }

    Try {
        Write-Host "Module Path : $ENV:BHProjectPath"
        Write-Host "Build System: $env:BHBuildSystem"
        Write-Host "Branch Name: $env:BHBranchName"
        Write-Host "Commit Message: $env:BHCommitMessage"
        $Params = @{
            Path = $ProjectRoot
            Force = $true
            Recurse = $false # We keep psdeploy.ps1 test artifacts, avoid deploying those : )
        }
        Invoke-PSDeploy @Params -Verbose:$true
    } Catch {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Output $ErrorMessage
        Write-Output $FailedItem
        throw "Can't publish to gallery."
    }
}