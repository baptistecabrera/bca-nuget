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

Describe "ConvertTo-NuspecManifest" {
    Write-Host -ForegroundColor Cyan "These tests should also confirm that Resolve-NuspecProperty, Set-NuspecProperty and Add-NuspecDependency are working as expected."
    Write-Host -ForegroundColor Cyan "Warning(s) on unmatched properties are expected."

    BeforeAll {
        $PSManifest = Join-Path $PSScriptRoot Bca.Nuget.psd1
        $NuspecManifest = Join-Path $env:TEMP "Bca.Nuget\Bca.Nuget.nuspec"
        $NuspecManifest2 = Join-Path $env:TEMP "Bca.Nuget\Bca.Nuget2.nuspec"
        $ChocoManifest = Join-Path $env:TEMP "Bca.Nuget\bca-nuget.nuspec"
        $ScriptPath = Join-Path $env:TEMP "Bca.Nuget\TestScript.ps1"
        $ScriptNuspecManifest = Join-Path $env:TEMP "Bca.Nuget\TestScript.nuspec"
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
            (Import-PowerShellDataFile -Path $PSManifest | ConvertTo-NuspecManifest -DependencyMatch $Match).Save($NuspecManifest)
            $Result = $true
        }
        catch { Write-Error $_ ; $Result = $false }
        $Result | Should -Be $true
    }

    It "Testing generated Nuspec file" {
        $Result = Test-Path $NuspecManifest
        $Result | Should -Be $true
    }

    It "Converting PS Module Manifest to Chocolatey Nuspec" {
        try
        {
            (Import-PowerShellDataFile -Path $PSManifest | ConvertTo-NuspecManifest -AcceptChocolateyProperties).Save($ChocoManifest)
            $Result = $true
        }
        catch { Write-Error $_ ; $Result = $false }
        $Result | Should -Be $true
    }

    It "Testing generated Chocolatey Nuspec file" {
        (Get-NuspecProperty -Name bugTrackerUrl).Value | Should -BeExactly "https://github.com/baptistecabrera/bca-nuget/issues"
        Test-Path $ChocoManifest | Should -Be $true
    }

    It "Converting PS Module Info to Nuspec" {
        try
        {
            $Result = $true
            (Get-Module -Name Bca.Nuget | ConvertTo-NuspecManifest -DependencyMatch $Match).Save($NuspecManifest2)
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

    It "Converting Script File Info to Nuspec" {
        try
        {
            $Result = $true
            New-ScriptFileInfo @ScriptInfo
            (Test-ScriptFileInfo -Path $ScriptPath | ConvertTo-NuspecManifest -DependencyMatch $Match).Save($ScriptNuspecManifest)
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
        $NuspecManifest = Join-Path $env:TEMP "Bca.Nuget\Bca.Nuget.nuspec"
        $ScriptNuspecManifest = Join-Path $env:TEMP "Bca.Nuget\TestScript.nuspec"
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
        $NuspecManifest = Join-Path $env:TEMP "Bca.Nuget\Bca.Nuget.nuspec"
        $Nuspec = [xml](Get-Content -Path $NuspecManifest)
    }
    

    It "Setting license from Expression" {
        try 
        {
            $Nuspec = Set-NuspecLicense -Type expression -Value "MIT" -Nuspec $Nuspec
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
            # $Nuspec = [xml](Get-Content -Path $NuspecManifest)
            $Nuspec = Set-NuspecLicense -Type expression -Value "MIT" -Nuspec $Nuspec
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
            # $Nuspec = [xml](Get-Content -Path $NuspecManifest)
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
            $Nuspec = Set-NuspecLicense -Type file -Value "\License.txt" -Nuspec $Nuspec -Force
        }
        catch
        {
            $Nuspec = [xml](Get-Content -Path $NuspecManifest)
        }
        $Nuspec.package.metadata.license.type | Should -BeExactly "file"
        $Nuspec.package.metadata.license.InnerText | Should -BeExactly "License.txt"
        ($Nuspec.package.files.file | Where-Object { $_.src -eq "\License.txt" }).src | Should -BeExactly "\License.txt"
    }
}

Describe "New-NuGetPackage" {
    Write-Host -ForegroundColor Cyan "This test should also confirm that Invoke-NuGetCommand is working as expected."

    BeforeAll {
        $NuspecManifest = Join-Path $env:TEMP "Bca.Nuget\Bca.Nuget.nuspec"
        $Nuspec = [xml](Get-Content -Path $NuspecManifest)
    }

    It "Creating package from Nuspec" {
        try
        {
            $Result = $true
            $PackageFile = Join-Path (Split-Path $NuspecManifest -Parent) "$((Get-NuspecProperty -Name id -Nuspec $Nuspec).Value).$((Get-NuspecProperty -Name version -Nuspec $Nuspec).Value).nupkg"
            if (Test-Path $PackageFile) { Remove-Item -Path $PackageFile -Force }
            New-NuGetPackage -Manifest $NuspecManifest -OutputPath (Split-Path $NuspecManifest -Parent) -Parameters @{ "NoDefaultExcludes" = $true } -ErrorAction Stop | Out-Null
        }
        catch
        {
            $Result = $false
        }
        $Result | Should -Be $true
        (Test-Path $PackageFile) | Should -Be $true
    }
}

Describe "Cleanup" {
    BeforeAll { $Directory = Join-Path $env:TEMP "Bca.Nuget" }
    
    It "Removing test directory ($Directory)" {
        Remove-Item -Path $Directory -Force -Recurse
    }

    It "Removing Module" {
        Remove-Module -Name Bca.Nuget -Force
    }
}