Describe "Module" {
    It "Importing module locally." {
        try
        {
            Import-Module (Join-Path $PSScriptRoot Bca.Nuget.psd1) -Force
            $Result = $true
        }
        catch { $Result = $false }
        $Result | Should Be $true
    }
    
    It "Checking exported commands count." {
        $Commands = Get-Command -Module Bca.Nuget
        $Commands.Count | Should BeGreaterThan 0
    }
}

Describe "ConvertTo-NuspecManifest" {
    Write-Host -ForegroundColor Cyan "These tests should also confirm that Resolve-NuspecProperty, Set-NuspecProperty and Add-NuspecDependency are working as expected."
    Write-Host -ForegroundColor Cyan "Warning(s) on unmatched properties are expected."

    $PSManifest = Join-Path $PSScriptRoot Bca.Nuget.psd1
    $NuspecManifest = Join-Path $env:TEMP "Bca.Nuget\Bca.Nuget.nuspec"
    $NuspecManifest2 = Join-Path $env:TEMP "Bca.Nuget\Bca.Nuget2.nuspec"
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
    
    It "Converting PS Module Manifest to Nuspec" {
        try
        {
            (Import-PowerShellDataFile -Path $PSManifest | ConvertTo-NuspecManifest -DependencyMatch $Match).Save($NuspecManifest)
            $Result = $true
        }
        catch { $Result = $false }
        $Result | Should Be $true
    }

    It "Testing generated Nuspec file" {
        $Result = Test-Path $NuspecManifest
        $Result | Should Be $true
    }

    It "Converting PS Module Info to Nuspec" {
        try
        {
            (Get-Module -Name Bca.Nuget | ConvertTo-NuspecManifest -DependencyMatch $Match).Save($NuspecManifest2)
            $Result = $true
        }
        catch { $Result = $false }
        $Result | Should Be $true
    }

    It "Testing generated Nuspec file" {
        $Result = Test-Path $NuspecManifest2
        $Result | Should Be $true
    }
    
    It "Testing both generated module Nuspec file" {
        $Result = ((Get-Content $NuspecManifest) -join "`r`n") -eq ((Get-Content $NuspecManifest2) -join "`r`n")
        $Result | Should Be $true
    }

    It "Converting Script File Info to Nuspec" {
        try
        {
            New-ScriptFileInfo @ScriptInfo
            (Test-ScriptFileInfo -Path $ScriptPath | ConvertTo-NuspecManifest -DependencyMatch $Match).Save($ScriptNuspecManifest)
            $Result = $true
        }
        catch { $Result = $false }
        $Result | Should Be $true
    }

    It "Testing generated Nuspec file" {
        $Result = Test-Path $ScriptNuspecManifest
        $Result | Should Be $true
    }
}

Describe "Get-NuspecProperty" {
    $NuspecManifest = Join-Path $env:TEMP "Bca.Nuget\Bca.Nuget.nuspec"
    $ScriptNuspecManifest = Join-Path $env:TEMP "Bca.Nuget\TestScript.nuspec"
    $Nuspec = [xml](Get-Content -Path $NuspecManifest)

    It "Getting Id by Path" {
        $Id = Get-NuspecProperty -Name "id" -Path $NuspecManifest
        $Id.Name | Should BeExactly "id"
        $Id.Value | Should BeExactly "Bca.Nuget"
    }

    It "Getting Id by Nuspec" {
        $Id = Get-NuspecProperty -Name "id" -Nuspec $Nuspec
        $Id.Name | Should BeExactly "id"
        $Id.Value | Should BeExactly "Bca.Nuget"
    }

    It "Getting script Title" {
        $Id = Get-NuspecProperty -Name "title" -Path $ScriptNuspecManifest
        $Id.Name | Should BeExactly "title"
        $Id.Value | Should BeExactly "TestScript"
    }
}

Describe "Set-NuspecLicense" {
    $NuspecManifest = Join-Path $env:TEMP "Bca.Nuget\Bca.Nuget.nuspec"
    $Nuspec = [xml](Get-Content -Path $NuspecManifest)

    It "Setting license from Expression" {
        try 
        {
            $Nuspec = Set-NuspecLicense -Type expression -Value "MIT" -Nuspec $Nuspec
        }
        catch
        {
            $Nuspec = [xml](Get-Content -Path $NuspecManifest)
        }
        $Nuspec.package.metadata.license.type | Should BeExactly "expression"
        $Nuspec.package.metadata.license.InnerText | Should BeExactly "MIT"
    }

    It "Setting license from Expression (!Force) - Should display a warning above ^" {
        try 
        {
            $Nuspec = Set-NuspecLicense -Type expression -Value "MIT AND AAL" -Nuspec $Nuspec
        }
        catch
        {
            $Nuspec = [xml](Get-Content -Path $NuspecManifest)
        }
        $Nuspec.package.metadata.license.type | Should BeExactly "expression"
        $Nuspec.package.metadata.license.InnerText | Should BeExactly "MIT"
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
        $Nuspec.package.metadata.license.type | Should BeExactly "expression"
        $Nuspec.package.metadata.license.InnerText | Should BeExactly "MIT AND AAL"
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
        $Nuspec.package.metadata.license.type | Should BeExactly "file"
        $Nuspec.package.metadata.license.InnerText | Should BeExactly "License.txt"
        $Nuspec.package.files.file | Where-Object { $_.src -eq "\License.txt" } | Should Be $true
    }

    It "Setting license from Expression (not approved) - Should display an exception above ^" {
        try 
        {
            $Result = $false
            Set-NuspecLicense -Type expression -Value "ADSL" -Nuspec $Nuspec -Force -ErrorAction Stop | Out-Null
        }
        catch
        {
            $Result = $true
        }
        $Result | Should Be $true
    }
}

Describe "New-NuGetPackage" {
    Write-Host -ForegroundColor Cyan "This test should also confirm that Invoke-NuGetCommand is working as expected."

    $NuspecManifest = Join-Path $env:TEMP "Bca.Nuget\Bca.Nuget.nuspec"
    $Nuspec = [xml](Get-Content -Path $NuspecManifest)
    $PackageFile = Join-Path (Split-Path $NuspecManifest -Parent) "$((Get-NuspecProperty -Name id -Nuspec $Nuspec).Value).$((Get-NuspecProperty -Name version -Nuspec $Nuspec).Value).nupkg"

    It "Creating package from Nuspec" {
        try
        {
            $Result = $false
            if (Test-Path $PackageFile) { Remove-Item -Path $PackageFile -Force }
            New-NuGetPackage -Manifest $NuspecManifest -OutputPath (Split-Path $NuspecManifest -Parent) -Parameters @{ "NoDefaultExcludes" = $true } -ErrorAction Stop | Out-Null
            $Result = $true
        }
        catch
        {
            $Result = $false
        }
        $Result | Should Be $true
        (Test-Path $PackageFile) | Should Be $true
    }
}

Describe "Cleanup" {
    $Directory = Join-Path $env:TEMP "Bca.Nuget"
    
    It "Removing test directory" {
        Remove-Item -Path $Directory -Force -Recurse
    }
}