function Set-NuspecProperty
{
    <#
        .SYNOPSIS
            Sets a property value in a Nuspec manifest.
        .DESCRIPTION
            Sets a property value in a Nuspec manifest.
        .PARAMETER Name
            A string containing the name of the property to be set.
        .PARAMETER Value
            An object containing the value(s) of the property.
        .PARAMETER Path
            A string containing the the full path of the Nuspec manifest file.
            The file will be saved after the property is set.
        .PARAMETER Nuspec
            An XmlDocument containing the Nuspec manifest.
        .PARAMETER AcceptChocolateyProperties
            A switch specifying whether or not to accept Chocolatey-specific properties.
        .PARAMETER Force
            A switch specifying whether or not to override teh value.
        .INPUTS
            System.Object
            Accepts an object containing the Name and Value as an input from the pipeline.
        .OUTPUTS
            System.Xml.XmlDocument
            Returns an XmlDocument containing the manifest.
        .EXAMPLE
            Set-NuspecProperty -Name "version" -Value "1.0.0" -Path .\package.nuspec

            Description
            -----------
            This example will set the property "version" value to "1.0.0", save the file, and return the manifest XmlDocument.
        .EXAMPLE
            Set-NuspecProperty -Name "dependencies" -Value @( "MyModule1", @{ ModuleName = "MyModule2" ; ModuleVersion = "1.0.0" }, @{ ModuleName = "MyModule3" ; RequiredVersion = "1.0.0" } ) -Nuspec $NuspecManifest

            Description
            -----------
            This example set multiple "dependency" properties under the property "dependencies" for each value in value and return the manifest XmlDocument.
        .EXAMPLE
            Resolve-NuspecProperty -Name "name" -Value "value" | Set-NuspecProperty -Nuspec $NuspecManifest

            Description
            -----------
            This example will resolve the property "name" and sets its value, then return the manifest XmlDocument.
        .NOTES
        .LINK
            Resolve-NuspecProperty
        .LINK
            Add-NuspecDependency
        .LINK
            https://docs.microsoft.com/en-us/nuget/reference/nuspec
    #>
    [CmdLetBinding()]
    param(
        [Parameter(ParameterSetName = "FromFile", Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = "FromXml", Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,
        [Parameter(ParameterSetName = "FromFile", Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = "FromXml", Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        $Value,
        [Parameter(ParameterSetName = "FromFile", Mandatory = $true)]
        [ValidateScript( { Test-Path $_ } )]
        [string] $Path,
        [Parameter(ParameterSetName = "FromXml", Mandatory = $true)]
        [xml] $Nuspec,
        [Parameter(ParameterSetName = "FromFile", Mandatory = $false)]
        [Parameter(ParameterSetName = "FromXml", Mandatory = $false)]
        [switch] $AcceptChocolateyProperties,
        [Parameter(ParameterSetName = "FromFile", Mandatory = $false)]
        [Parameter(ParameterSetName = "FromXml", Mandatory = $false)]
        [switch] $Force
    )

    try
    {
        if ($PSCmdlet.ParameterSetName -eq "FromFile") { [xml] $Nuspec = Get-Content $Path }
        if ($Name)
        {
            Write-Verbose "Setting property '$Name' to '$Value'."
            switch -Regex ($Name)
            {
                "^version$"
                {
                    if ($Force)
                    {
                        $Nuspec.package.metadata.version = "$($Value.ToString())"
                    }
                    else
                    {
                        if ($Nuspec.package.metadata.version) { $Nuspec.package.metadata.version = "$($Value)$($Nuspec.package.metadata.version)" }
                        else { $Nuspec.package.metadata.version = "$($Value.ToString())" }
                    }
                }
                "Prerelease"
                {
                    if ($Nuspec.package.metadata.version) { $Nuspec.package.metadata.version = "$($Nuspec.package.metadata.version)$($Value)" }
                    else { $Nuspec.package.metadata.version = "$($Value.ToString())" }
                }
                "^description$|^summary$|^id$|^title$|^authors$|^owners$|^copyright$|^projectUrl$|^iconUrl$|^tags$|^releaseNotes$"
                {
                    if (!$Nuspec.package.metadata.$Name)
                    {
                        $NewMetadata = $Nuspec.CreateElement($Name, $Nuspec.package.xmlns)
                        $Nuspec.GetElementsByTagName("metadata").AppendChild($NewMetadata)
                    }
                    $Nuspec.package.metadata.$Name = $Value
                }
                "^licenseUrl$"
                {
                    if (!$Nuspec.package.metadata.license -or $AcceptChocolateyProperties)
                    {
                        if (!$AcceptChocolateyProperties) { Write-Warning "Property 'licenseUrl' is being deprecated, consider using 'license' instead." }
                        if (!$Nuspec.package.metadata.$Name)
                        {
                            $NewMetadata = $Nuspec.CreateElement($Name, $Nuspec.package.xmlns)
                            $Nuspec.GetElementsByTagName("metadata").AppendChild($NewMetadata)
                        }
                        $Nuspec.package.metadata.$Name = $Value
                    }
                    else { Write-Warning "Property 'license' already present, ignoring property 'licenseUrl' as it is being deprecated." }
                }
                "^license$"
                {
                    if ($AcceptChocolateyProperties) { Write-Warning "Property 'license' not yet supported by Chocolatey, use 'licenseUrl' instead." }
                    else 
                    {
                        $LicenseFile = Get-Item $Value -ErrorAction SilentlyContinue
                        if ($LicenseFile) { $LicenseType = "file" }
                        else { $LicenseType = "expression" }
                        $Nuspec = Set-NuspecLicense -Type $LicenseType -Value $Value -Nuspec $Nuspec -Force
                    }
                }
                "dependencies"
                {
                    $Nuspec = Add-NuspecDependency -InputObject $Value -Nuspec $Nuspec
                }
                "^docsUrl$|^mailingListUrl$|^bugTrackerUrl$|^packageSourceUrl$|^projectSourceUrl$"
                {
                    if ($AcceptChocolateyProperties)
                    {
                        if (!$Nuspec.package.metadata.$Name)
                        {
                            $NewMetadata = $Nuspec.CreateElement($Name, $Nuspec.package.xmlns)
                            $Nuspec.GetElementsByTagName("metadata").AppendChild($NewMetadata)
                        }
                        $Nuspec.package.metadata.$Name = $Value
                    }
                    else { Write-Warning "Property '$Name' does not match any mapped Nuspec property." }
                }
                default
                {
                    Write-Warning "Property '$Name' does not match any mapped Nuspec property."
                }
            }
        }

        if ($PSCmdlet.ParameterSetName -eq "FromFile") { $Nuspec.Save($Path) }

        $Nuspec
    }
    catch
    {
        Write-Error $_
    }
}