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
    if (!(Test-Path (Split-Path $NuspecManifest -Parent))) { New-Item -Path (Split-Path $NuspecManifest -Parent) -ItemType Directory -Force | Out-Null }

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
}

Describe "Get-NuspecProperty" {
    $NuspecManifest = Join-Path $env:TEMP "Bca.Nuget\Bca.Nuget.nuspec"
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