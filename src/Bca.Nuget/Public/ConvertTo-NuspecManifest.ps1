function ConvertTo-NuspecManifest
{
    <#
        .SYNOPSIS
            Converts an object to a NuspecManifest.
        .DESCRIPTION
            Converts an object to a NuspecManifest.
        .PARAMETER InputObject
            An object containing the specifications to be converted into a Nuspec manifest.
        .INPUTS
            System.Object
            Accepts an object representing data that can be mapped to Nuspec properties and converted to a Nuspec manifest.
        .OUTPUTS
            System.Xml.XmlDocument
            Returns an XmlDocument containing the manifest.
        .EXAMPLE
            ConvertTo-NuspecManifest -InputObject ((Get-Content .\package.json) | Convert-From-Json)

            Description
            -----------
            This example will get the content of "package.json" and map properties to create a Nuspec manifest.
        .EXAMPLE
            ConvertTo-NuspecManifest -InputObject (Import-PowerShellDataFile -Path .\MyModule.psd1)

            Description
            -----------
            This example will import the PowerShell module manifest "MyModule.psd1" and map properties to create a Nuspec manifest.
            Import-PowerShellDataFile only works with PowerShell v5+, for v4 use Import-LocalizedData.
        .NOTES
            This version supports mostly PowerShell module manifest properties.
        .LINK
            Get-NuspecProperty
        .LINK
            Set-NuspecProperty
        .LINK
            https://docs.microsoft.com/en-us/nuget/reference/nuspec
    #>
    [CmdLetBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateScript( {
                try
                {
                    $_ | ConvertTo-Json -Depth 100 | ConvertFrom-Json
                    $true
                }
                catch { throw "Could not convert input object type '$($InputObject.GetType().Name)'." }
            } )]
        $InputObject,
        [Parameter(Mandatory = $false)]
        $DependencyMatch
    )
    
    try 
    {
        [xml] $Nuspec = Get-Content (Join-Path (Join-Path (Split-Path $PSScriptRoot -Parent) "template") "template.nuspec.xml")
        
        Write-Verbose "Input object type is '$($InputObject.GetType().Name)'"
        $InputObject = $InputObject | ConvertTo-Json -Depth 100 | ConvertFrom-Json
    
        $InputObject | Get-Member -MemberType NoteProperty | ForEach-Object {
            $Current = $_
            Write-Verbose $Current
            switch -Regex ($InputObject."$($Current.Name)".GetType().Name)
            {
                "string"
                {
                    Resolve-NuspecProperty -Name $Current.Name -Value $InputObject."$($Current.Name)" | Set-NuspecProperty -Nuspec $Nuspec -ErrorAction SilentlyContinue | Out-Null
                }
                "object"
                {
                    if ($Current.Name -eq "RequiredModules") { Add-NuspecDependency -InputObject $InputObject."$($Current.Name)" -Match $DependencyMatch -Nuspec $Nuspec | Out-Null }
                    elseif ($Current.Name -eq "PrivateData")
                    {
                        if ($InputObject."$($Current.Name)".PSData.Tags) { Resolve-NuspecProperty -Name "Tags" -Value $InputObject."$($Current.Name)".PSData.Tags | Set-NuspecProperty -Nuspec $Nuspec | Out-Null }
                        if ($InputObject."$($Current.Name)".PSData.LicenseUri) { Resolve-NuspecProperty -Name "LicenseUri" -Value $InputObject."$($Current.Name)".PSData.LicenseUri | Set-NuspecProperty -Nuspec $Nuspec | Out-Null }
                        if ($InputObject."$($Current.Name)".PSData.ProjectUri) { Resolve-NuspecProperty -Name "ProjectUri" -Value $InputObject."$($Current.Name)".PSData.ProjectUri | Set-NuspecProperty -Nuspec $Nuspec | Out-Null }
                        if ($InputObject."$($Current.Name)".PSData.IconUri) { Resolve-NuspecProperty -Name "IconUri" -Value $InputObject."$($Current.Name)".PSData.IconUri | Set-NuspecProperty -Nuspec $Nuspec | Out-Null }
                        if ($InputObject."$($Current.Name)".PSData.ReleaseNotes) { Resolve-NuspecProperty -Name "ReleaseNotes" -Value $InputObject."$($Current.Name)".PSData.ReleaseNotes | Set-NuspecProperty -Nuspec $Nuspec | Out-Null }
                        if ($InputObject."$($Current.Name)".PSData.Prerelease) { Resolve-NuspecProperty -Name "Prerelease" -Value $InputObject."$($Current.Name)".PSData.Prerelease | Set-NuspecProperty -Nuspec $Nuspec | Out-Null }
                    }
                    else
                    {
                        Write-Warning "Unsupported property '$Current.Name'"
                    }
                }
                default
                {
                    Write-Warning "Unsupported type '$($InputObject."$($Current.Name)".GetType().Name)'"
                }
            }
        }

        if ((!$Nuspec.package.metadata.title) -and $Nuspec.package.metadata.id)
        {
            Write-Verbose "No 'title' property found, using 'id' value ($($Nuspec.package.metadata.id)) as 'title'."
            Set-NuspecProperty -Name "title" -Value $Nuspec.package.metadata.id -Nuspec $Nuspec | Out-Null
        }

        $Nuspec
    }
    catch
    {
        Write-Error $_
    }
}