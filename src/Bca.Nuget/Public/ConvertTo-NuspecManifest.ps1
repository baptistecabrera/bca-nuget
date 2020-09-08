function ConvertTo-NuspecManifest
{
    <#
        .SYNOPSIS
            Converts an object to a NuspecManifest.
        .DESCRIPTION
            Converts an object to a NuspecManifest.
        .PARAMETER InputObject
            An object containing the specifications to be converted into a Nuspec manifest.
        .PARAMETER AcceptChocolateyProperties
            A switch specifying whether or not to accept Chocolatey-specific properties.
        .PARAMETER DependencyMatch
            A string containing a regular expression to match the dependencies against.
            If used and a dependency does not match, it will be excluded fro the resulting nuspec manifest.
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
            Import-PowerShellDataFile -Path .\MyModule.psd1 | ConvertTo-NuspecManifest

            Description
            -----------
            This example will import the PowerShell module manifest "MyModule.psd1" and map properties to create a Nuspec manifest.
            Import-PowerShellDataFile only works with PowerShell v5+, for v4 use Import-LocalizedData.
        .EXAMPLE
            Get-Module MyModule | ConvertTo-NuspecManifest

            Description
            -----------
            This example will get the PowerShell module MyModule and map properties to create a Nuspec manifest.
        .EXAMPLE
            Test-ScriptFileInfo C:\MyScript.ps1 | ConvertTo-NuspecManifest

            Description
            -----------
            This example will get the script file info of the PowerShell script MyScript.ps1 and map properties to create a Nuspec manifest.
        .NOTES
            This version supports mostly PowerShell Module amd Scripts File Info properties.
        .LINK
            Get-NuspecProperty
        .LINK
            Set-NuspecProperty
        .LINK
            Resolve-NuspecProperty
        .LINK
            https://docs.microsoft.com/en-us/nuget/reference/nuspec
    #>
    [CmdLetBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateScript( {
                try
                {
                    $_ | ConvertTo-Json | ConvertFrom-Json
                    $true
                }
                catch { throw "Could not convert input object type '$($InputObject.GetType().Name)'." }
            } )]
        $InputObject,
        [Parameter(Mandatory = $false)]
        [switch] $AcceptChocolateyProperties,
        [Parameter(Mandatory = $false)]
        $DependencyMatch
    )
    
    try 
    {
        [xml] $Nuspec = Get-Content (Join-Path (Join-Path (Split-Path $PSScriptRoot -Parent) "template") "template.nuspec.xml")
        
        Write-Verbose "Input object type is '$($InputObject.GetType().Name)'"
        $InputObject = $InputObject | ConvertTo-Json | ConvertFrom-Json
    
        $InputObject | Get-Member -MemberType NoteProperty | Where-Object { $InputObject."$($_.Name)" -and ($_.Name -notlike "Exported*") -and ($_.Name -notin "SessionState", "Definition") } | ForEach-Object {
            $Current = $_
            Write-Debug $Current
            switch -Regex ($InputObject."$($Current.Name)".GetType().Name)
            {
                "PSCustomObject"
                {
                    $InputObject."$($Current.Name)" | Get-Member -MemberType NoteProperty | Where-Object { $InputObject."$($Current.Name)"."$($_.Name)" } | ForEach-Object {
                        $SubCurrent = $_
                        if ($InputObject."$($Current.Name)"."$($SubCurrent.Name)".GetType().Name -eq "PSCustomObject")
                        {
                            $InputObject."$($Current.Name)"."$($SubCurrent.Name)" | Get-Member -MemberType NoteProperty | Where-Object { $InputObject."$($Current.Name)"."$($SubCurrent.Name)"."$($_.Name)" } | ForEach-Object {
                                Resolve-NuspecProperty -Name $_.Name -Value $InputObject."$($Current.Name)"."$($SubCurrent.Name)"."$($_.Name)" -AcceptChocolateyProperties:$AcceptChocolateyProperties | Set-NuspecProperty -Nuspec $Nuspec -AcceptChocolateyProperties:$AcceptChocolateyProperties -ErrorAction SilentlyContinue | Out-Null
                            }
                        }
                        else { Resolve-NuspecProperty -Name $SubCurrent.Name -Value $InputObject."$($Current.Name)"."$($SubCurrent.Name)" -AcceptChocolateyProperties:$AcceptChocolateyProperties | Set-NuspecProperty -Nuspec $Nuspec -AcceptChocolateyProperties:$AcceptChocolateyProperties -ErrorAction SilentlyContinue | Out-Null }
                    }
                }
                default { Resolve-NuspecProperty -Name $Current.Name -Value $InputObject."$($Current.Name)" -AcceptChocolateyProperties:$AcceptChocolateyProperties | Set-NuspecProperty -Nuspec $Nuspec -AcceptChocolateyProperties:$AcceptChocolateyProperties -ErrorAction SilentlyContinue | Out-Null }
            }
        }

        if ((!$Nuspec.package.metadata.title) -and $Nuspec.package.metadata.id)
        {
            Write-Verbose "No 'title' property found, using 'id' value ($($Nuspec.package.metadata.id)) as 'title'."
            Set-NuspecProperty -Name "title" -Value $Nuspec.package.metadata.id -Nuspec $Nuspec | Out-Null
        }
        if ((!$Nuspec.package.metadata.summary) -and $Nuspec.package.metadata.description -and $AcceptChocolateyProperties)
        {
            Write-Verbose "No 'summary' property found, using 'description' value ($($Nuspec.package.metadata.description)) as 'summary'."
            Set-NuspecProperty -Name "summary" -Value $Nuspec.package.metadata.description -Nuspec $Nuspec | Out-Null
        }

        $Nuspec
    }
    catch
    {
        Write-Error $_
    }
}