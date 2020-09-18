Describe "Module" {
    BeforeAll { $PSManifest = Join-Path $PSScriptRoot Bca.Nuget.psd1 }

    It "Importing module locally." {
        try
        {
            Import-Module $PSManifest -Force
            $Result = $true
        }
        catch { $Result = $false }
        $Result | Should -Be $true
    }
    
    It "Checking exported commands count." {
        $Commands = Get-Command -Module Bca.Nuget
        $Commands.Count | Should -BeGreaterThan 0
    }
}

Describe "Install-NuGet/Update-NuGet" {
    It "Installing NuGet" {
        try
        {
            Install-NuGet
            $Result = $true
        }
        catch { $Result = $false }
        $Result | Should -Be $true
    }

    It "Updating NuGet" {
        try
        {
            Update-NuGet
            $Result = $true
        }
        catch { $Result = $false }
        $Result | Should -Be $true
    }
}

Describe "Get-NuspecSchema" {
    It "Getting Nuspec Schema" {
        try
        {
            $Schema = Get-NuspecSchema
            $Result = $true
        }
        catch { $Result = $false }
        $Result | Should -Be $true
    }
}
Describe "ConvertTo-NuspecManifest/Save-NuspecManifest" {

    BeforeAll {
        Write-Host -ForegroundColor Cyan "These tests should also confirm that Resolve-NuspecProperty, Set-NuspecProperty and Add-NuspecDependency are working as expected."
        Write-Host -ForegroundColor Cyan "Warning(s) on unmatched properties are expected."

        $PSManifest = Join-Path $PSScriptRoot Bca.Nuget.psd1
        $PSData = Import-PowerShellDataFile -Path $PSManifest
        $NuspecManifest = Join-Path ([System.IO.Path]::GetTempPath()) "Bca.Nuget/Bca.Nuget.nuspec"
        $NuspecManifest2 = Join-Path ([System.IO.Path]::GetTempPath()) "Bca.Nuget/Bca.Nuget2.nuspec"
        $ChocoManifest = Join-Path ([System.IO.Path]::GetTempPath()) "Bca.Nuget/bca-nuget.nuspec"
        $ScriptPath = Join-Path ([System.IO.Path]::GetTempPath()) "Bca.Nuget/TestScript.ps1"
        $ScriptNuspecManifest = Join-Path ([System.IO.Path]::GetTempPath()) "Bca.Nuget/TestScript.nuspec"
        if (!(Test-Path (Split-Path $NuspecManifest -Parent))) { New-Item -Path (Split-Path $NuspecManifest -Parent) -ItemType Directory -Force | Out-Null }
        if (!(Test-Path (Split-Path $NuspecManifest2 -Parent))) { New-Item -Path (Split-Path $NuspecManifest2 -Parent) -ItemType Directory -Force | Out-Null }
        if (!(Test-Path (Split-Path $ScriptNuspecManifest -Parent))) { New-Item -Path (Split-Path $ScriptNuspecManifest -Parent) -ItemType Directory -Force | Out-Null }
        

        $ScriptInfo = @{
            Path                       = $ScriptPath
            Version                    = "1.0.0"
            Author                     = "pattif@contoso.com"
            Description                = "My new script file test"
            CompanyName                = "Contoso Corporation"
            Copyright                  = "2019 Contoso Corporation. All rights reserved."
            ExternalModuleDependencies = "ff", "bb"
            RequiredScripts            = "Start-WFContosoServer", "Stop-ContosoServerScript"
            ExternalScriptDependencies = "Stop-ContosoServerScript"
            Tags                       = @("Tag1", "Tag2", "Tag3")
            ProjectUri                 = "https://contoso.com"
            LicenseUri                 = "https://contoso.com/License"
            IconUri                    = "https://contoso.com/Icon"
            PassThru                   = $True
            ReleaseNotes               = @("Contoso script now supports the following features:",
                "Feature 1",
                "Feature 2",
                "Feature 3",
                "Feature 4",
                "Feature 5")
            RequiredModules            =
            "1",
            "2",
            "RequiredModule1",
            @{ModuleName = "RequiredModule2"; ModuleVersion = "1.0" },
            @{ModuleName = "RequiredModule3"; RequiredVersion = "2.0" },
            "ExternalModule1"
        }
    }
    
    It "Converting PS Module Manifest to Nuspec" {
        try
        {
            Import-PowerShellDataFile -Path $PSManifest | ConvertTo-NuspecManifest -DependencyMatch $Match | Save-NuspecManifest -Path (Split-Path $NuspecManifest -Parent)
            $Result = $true
        }
        catch { Write-Error $_ ; $Result = $false }
        $Result | Should -Be $true
    }

    It "Testing generated Nuspec file" {
        $Result = Test-Path $NuspecManifest
        $Result | Should -Be $true
    }

    It "Converting PS Module Info to Nuspec" {
        try
        {
            $Result = $true
            Get-Module -Name Bca.Nuget | ConvertTo-NuspecManifest -DependencyMatch $Match | Save-NuspecManifest -Path $NuspecManifest2
        }
        catch { $Result = $false }
        $Result | Should -Be $true
    }

    It "Testing generated Nuspec file" {
        $Result = Test-Path $NuspecManifest2
        $Result | Should -Be $true
    }
    
    It "Testing both generated module Nuspec file" {
        $Result = ((Get-Content $NuspecManifest) -join "`r`n") -eq ((Get-Content $NuspecManifest2) -join "`r`n")
        $Result | Should -Be $true
    }

    It "Converting PS Module Manifest to Chocolatey Nuspec" {
        try
        {
            $PSData | ConvertTo-NuspecManifest -AcceptChocolateyProperties | Save-NuspecManifest -Path $ChocoManifest
            $Result = $true
        }
        catch { Write-Error $_ ; $Result = $false }
        $Result | Should -Be $true
    }

    It "Testing generated Chocolatey Nuspec file" {
        Test-Path $ChocoManifest | Should -Be $true
        (Get-NuspecProperty -Name bugTrackerUrl -Path $ChocoManifest).Value | Should -BeExactly $PSData.PrivateData.bugTrackerUrl
    }

    It "Converting Script File Info to Nuspec" {
        try
        {
            $Result = $true
            New-ScriptFileInfo @ScriptInfo
            Test-ScriptFileInfo -Path $ScriptPath | ConvertTo-NuspecManifest -DependencyMatch $Match | Save-NuspecManifest -Path $ScriptNuspecManifest
        }
        catch { $Result = $false }
        $Result | Should -Be $true
    }

    It "Testing generated Nuspec file" {
        $Result = Test-Path $ScriptNuspecManifest
        $Result | Should -Be $true
    }
}

Describe "Get-NuspecProperty" {
    BeforeAll {
        $NuspecManifest = Join-Path ([System.IO.Path]::GetTempPath()) "Bca.Nuget/Bca.Nuget.nuspec"
        $ScriptNuspecManifest = Join-Path ([System.IO.Path]::GetTempPath()) "Bca.Nuget/TestScript.nuspec"
    }

    It "Getting Id by Path" {
        $Id = Get-NuspecProperty -Name "id" -Path $NuspecManifest
        $Id.Name | Should -BeExactly "id"
        $Id.Value | Should -BeExactly "Bca.Nuget"
    }

    It "Getting Id by Nuspec" {
        $Nuspec = [xml](Get-Content -Path $NuspecManifest)
        $Id = Get-NuspecProperty -Name "id" -Nuspec $Nuspec
        $Id.Name | Should -BeExactly "id"
        $Id.Value | Should -BeExactly "Bca.Nuget"
    }

    It "Getting script Title" {
        $Id = Get-NuspecProperty -Name "title" -Path $ScriptNuspecManifest
        $Id.Name | Should -BeExactly "title"
        $Id.Value | Should -BeExactly "TestScript"
    }
}

Describe "Set-NuspecLicense" {
    BeforeAll {
        $NuspecManifest = Join-Path ([System.IO.Path]::GetTempPath()) "Bca.Nuget/Bca.Nuget.nuspec"
        $Nuspec = [xml](Get-Content -Path $NuspecManifest)
    }
    

    It "Setting license from Expression" {
        try 
        {
            $Nuspec = Set-NuspecLicense -Type expression -Value "MIT" -Nuspec $Nuspec -Force
        }
        catch
        {
            $Nuspec = [xml](Get-Content -Path $NuspecManifest)
        }
        $Nuspec.package.metadata.license.type | Should -BeExactly "expression"
        $Nuspec.package.metadata.license.InnerText | Should -BeExactly "MIT"
    }

    It "Setting license from Expression (!Force) - Should display a warning above ^" {
        try 
        {
            $Nuspec = Set-NuspecLicense -Type expression -Value "MIT AND ALL" -Nuspec $Nuspec
        }
        catch
        {
            $Nuspec = [xml](Get-Content -Path $NuspecManifest)
        }
        $Nuspec.package.metadata.license.type | Should -BeExactly "expression"
        $Nuspec.package.metadata.license.InnerText | Should -BeExactly "MIT"
    }

    It "Setting license from Expression (Force)" {
        try 
        {
            $Nuspec = Set-NuspecLicense -Type expression -Value "MIT AND AAL" -Nuspec $Nuspec -Force
        }
        catch
        {
            $Nuspec = [xml](Get-Content -Path $NuspecManifest)
        }
        $Nuspec.package.metadata.license.type | Should -BeExactly "expression"
        $Nuspec.package.metadata.license.InnerText | Should -BeExactly "MIT AND AAL"
    }

    It "Setting license from File" {
        try 
        {
            Write-Host -ForegroundColor Cyan "This test should also confirm that Add-NuspecFile is working as expected."
            $Nuspec = Set-NuspecLicense -Type file -Value "/License.txt" -Nuspec $Nuspec -Force
        }
        catch
        {
            $Nuspec = [xml](Get-Content -Path $NuspecManifest)
        }
        $Nuspec.package.metadata.license.type | Should -BeExactly "file"
        $Nuspec.package.metadata.license.InnerText | Should -BeExactly "License.txt"
        ($Nuspec.package.files.file | Where-Object { $_.src -eq "/License.txt" }).src | Should -BeExactly "/License.txt"
    }
}

Describe "Resolve-NuspecRepository/Set-NuspecRepository" {
    BeforeAll {
        $NuspecManifest = Join-Path ([System.IO.Path]::GetTempPath()) "Bca.Nuget/Bca.Nuget.nuspec"
        $Nuspec = [xml](Get-Content -Path $NuspecManifest)
        $BaseRepoUrl = "https://github.com/baptistecabrera/bca-nuget"
    }
    
    It "Setting repository from base URL" {
        try 
        {
            $Repository = Resolve-NuspecRepository -Uri $BaseRepoUrl
            $Nuspec = $Repository | Set-NuspecRepository -Nuspec $Nuspec -Force
        }
        catch
        {
            $Nuspec = [xml](Get-Content -Path $NuspecManifest)
        }
        $Repository.Type | Should -BeExactly "git"
        $Nuspec.package.metadata.repository.type | Should -BeExactly "git"
        $Repository.Uri | Should -BeExactly ("{0}.git" -f $BaseRepoUrl)
        $Nuspec.package.metadata.repository.url | Should -BeExactly ("{0}.git" -f $BaseRepoUrl)
    }

    It "Setting repository from #branch" {
        try 
        {
            $Uri = ("{0}.git#master" -f $BaseRepoUrl)
            $Repository = Resolve-NuspecRepository -Uri $Uri
            $Nuspec = $Repository | Set-NuspecRepository -Nuspec $Nuspec -Force
        }
        catch
        {
            $Nuspec = [xml](Get-Content -Path $NuspecManifest)
        }
        $Repository.Type | Should -BeExactly "git"
        $Nuspec.package.metadata.repository.type | Should -BeExactly "git"
        $Repository.Uri | Should -BeExactly ("{0}.git" -f $BaseRepoUrl)
        $Nuspec.package.metadata.repository.url | Should -BeExactly ("{0}.git" -f $BaseRepoUrl)
        $Repository.Branch | Should -BeExactly "master"
        $Nuspec.package.metadata.repository.branch | Should -BeExactly "master"
    }

    It "Setting repository from /tree/develop" {
        try 
        {
            $Uri = ("{0}/tree/develop" -f $BaseRepoUrl)
            $Repository = Resolve-NuspecRepository -Uri $Uri
            $Nuspec = $Repository | Set-NuspecRepository -Nuspec $Nuspec -Force
        }
        catch
        {
            $Nuspec = [xml](Get-Content -Path $NuspecManifest)
        }
        $Repository.Type | Should -BeExactly "git"
        $Nuspec.package.metadata.repository.type | Should -BeExactly "git"
        $Repository.Uri | Should -BeExactly ("{0}.git" -f $BaseRepoUrl)
        $Nuspec.package.metadata.repository.url | Should -BeExactly ("{0}.git" -f $BaseRepoUrl)
        $Repository.Branch | Should -BeExactly "develop"
        $Nuspec.package.metadata.repository.branch | Should -BeExactly "develop"
    }

    It "Setting repository from /commit/commitId" {
        try 
        {
            $Uri = ("{0}/commit/301dfbdd6dc116e3426399acbebb28fe5561351e" -f $BaseRepoUrl)
            $Repository = Resolve-NuspecRepository -Uri $Uri
            $Nuspec = $Repository | Set-NuspecRepository -Nuspec $Nuspec -Force
        }
        catch
        {
            $Nuspec = [xml](Get-Content -Path $NuspecManifest)
        }
        $Repository.Type | Should -BeExactly "git"
        $Nuspec.package.metadata.repository.type | Should -BeExactly "git"
        $Repository.Uri | Should -BeExactly ("{0}.git" -f $BaseRepoUrl)
        $Nuspec.package.metadata.repository.url | Should -BeExactly ("{0}.git" -f $BaseRepoUrl)
        $Repository.Commit | Should -BeExactly "301dfbdd6dc116e3426399acbebb28fe5561351e"
        $Nuspec.package.metadata.repository.commit | Should -BeExactly "301dfbdd6dc116e3426399acbebb28fe5561351e"
    }

    It "Setting repository from /blob/commitId" {
        try 
        {
            $Uri = ("{0}/blob/301dfbdd6dc116e3426399acbebb28fe5561351e" -f $BaseRepoUrl)
            $Repository = Resolve-NuspecRepository -Uri $Uri
            $Nuspec = $Repository | Set-NuspecRepository -Nuspec $Nuspec -Force
        }
        catch
        {
            $Nuspec = [xml](Get-Content -Path $NuspecManifest)
        }
        $Repository.Type | Should -BeExactly "git"
        $Nuspec.package.metadata.repository.type | Should -BeExactly "git"
        $Repository.Uri | Should -BeExactly ("{0}.git" -f $BaseRepoUrl)
        $Nuspec.package.metadata.repository.url | Should -BeExactly ("{0}.git" -f $BaseRepoUrl)
        $Repository.Commit | Should -BeExactly "301dfbdd6dc116e3426399acbebb28fe5561351e"
        $Nuspec.package.metadata.repository.commit | Should -BeExactly "301dfbdd6dc116e3426399acbebb28fe5561351e"
    }

}

Describe "New-NuGetPackage" -Tags "WindowsOnly" {

    BeforeAll {
        Write-Host -ForegroundColor Cyan "This test should also confirm that Invoke-NuGetCommand is working as expected."
        $NuspecManifest = Join-Path ([System.IO.Path]::GetTempPath()) "Bca.Nuget/Bca.Nuget.nuspec"
        $Nuspec = [xml](Get-Content -Path $NuspecManifest)
    }

    It "Creating package from Nuspec" {
        try
        {
            $Result = $true
            $PackageFile = Join-Path (Split-Path $NuspecManifest -Parent) "$((Get-NuspecProperty -Name id -Nuspec $Nuspec).Value).$((Get-NuspecProperty -Name version -Nuspec $Nuspec).Value).nupkg"
            if (Test-Path $PackageFile) { Remove-Item -Path $PackageFile -Force }
            New-NuGetPackage -Manifest $NuspecManifest -OutputPath (Split-Path $PackageFile -Parent) -Parameters @{ "NoDefaultExcludes" = $true } -ErrorAction Stop | Out-Null
        }
        catch
        {
            $Result = $false
        }
        $Result | Should -Be $true
        (Test-Path $PackageFile) | Should -Be $true
    }
}

Describe "Test-NuspecManifest" {

    BeforeAll {
        $Pscx = Get-Module -Name Pscx -ListAvailable
        if (!$Pscx) { Find-Module Pscx | Install-Module -Scope CurrentUser -AllowClobber -Force }
        $NuspecManifest = Join-Path ([System.IO.Path]::GetTempPath()) "Bca.Nuget/Bca.Nuget.nuspec"
        $Nuspec = [xml](Get-Content -Path $NuspecManifest)
    }

    It "Testing Nuspec Manifest from Path" {
        try
        {
            Import-Module Pscx -Force
            $Result = Test-NuspecManifest -Path $NuspecManifest
        }
        catch
        {
            $Result = $false
        }
        $Result | Should -Be $true
    }

    It "Testing Nuspec Manifest from Nuspec" {
        try
        {
            Import-Module Pscx -Force
            $Result = Test-NuspecManifest -Nuspec $Nuspec
        }
        catch
        {
            $Result = $false
        }
        $Result | Should -Be $true
    }
}

Describe "Add-NuspecContentFile" {

    BeforeAll {
        $NuspecManifest = Join-Path ([System.IO.Path]::GetTempPath()) "Bca.Nuget/Bca.Nuget.nuspec"
        $Nuspec = [xml](Get-Content -Path $NuspecManifest)

        $Include = "**/*.ps1"
        $Exclude = "**/*.exe"
        $BuildAction = "none"
    }

    It "Adding content files" {
        try
        {
            $Nuspec = Add-NuspecContentFile -Include $Include -Exclude $Exclude -BuildAction $BuildAction -CopyToOutput -Flatten -Nuspec $Nuspec
            $ContentFiles = (Get-NuspecProperty -Nuspec $Nuspec -Name contentFiles).Value
            $Result = $true
        }
        catch
        {
            $Result = $false
        }
        $Result | Should -Be $true
        $ContentFiles.include | Should -BeExactly $Include
        $ContentFiles.exclude | Should -BeExactly $Exclude
        $ContentFiles.buildAction | Should -BeExactly $BuildAction
        $ContentFiles.copyToOutput | Should -BeExactly $true
        $ContentFiles.flatten | Should -BeExactly $true
    }
}

Describe "Cleanup" {
    BeforeAll { $Directory = Join-Path ([System.IO.Path]::GetTempPath()) "Bca.Nuget" }
    
    It "Removing test directory ($Directory)" {
        Remove-Item -Path $Directory -Force -Recurse
    }

    It "Removing Module" {
        Remove-Module -Name Bca.Nuget -Force
    }
}