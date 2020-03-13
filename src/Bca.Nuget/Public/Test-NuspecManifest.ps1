function Test-NuspecManifest
{
    <#
        .SYNOPSIS
            Tests a Nuspec manifest.
        .DESCRIPTION
            Tests a Nuspec manifest against an xsd schema.
        .PARAMETER Path
            A string containing the full path to the Nuspec manifest file.
        .PARAMETER Nuspec
            An XmlDocument containing the Nuspec manifest.
        .PARAMETER Schema
            A string containing either the content or the full path of the xsd schema.
            Will use 'Get-NuspecSchema' if omitted.
        .INPUTS
        .OUTPUTS
            System.Boolean
            Returns a boolean specifying whether or not the manifest is conform to teh schema.
        .EXAMPLE
            Test-NuspecManifest -Path .\package.nuspec -Schema .\nuspec.xsd

            Description
            -----------
            This example will test the file 'package.nuspec' against the schema 'nuspec.xsd'.
        .EXAMPLE
            Test-NuspecManifest -Nuspec $NuspecContent

            Description
            -----------
            This example will test the xml document contained in a variable against the default Nuspec schema.
        .NOTES
        .LINK
            Get-NuspecSchema
        .LINK
            https://docs.microsoft.com/en-us/nuget/reference/nuspec
        .LINK
            https://raw.githubusercontent.com/MyGet/NuGetPackages/master/NuSpec/tools/nuspec.xsd
    #>
    [CmdLetBinding()]
    param(
        [Parameter(ParameterSetName = "FromFile", Mandatory = $true)]
        [ValidateScript( { Test-Path $_ } )]
        [string] $Path,
        [Parameter(ParameterSetName = "FromXml", Mandatory = $true)]
        [xml] $Nuspec,
        [Parameter(ParameterSetName = "FromFile", Mandatory = $false)]
        [Parameter(ParameterSetName = "FromXml", Mandatory = $false)]
        [string] $Schema = (Get-NuspecSchema)
    )

    try
    {
        if ($PSCmdlet.ParameterSetName -eq "FromXml")
        {
            Write-Verbose "Saving Nuspec xml in a temporary location ($($env:TEMP)\temp.nuspec)."
            $NuspecPath = Join-Path $env:TEMP temp.nuspec
            $Nuspec.Save($NuspecPath)
            $Path = $NuspecPath
        }
        if (!(Test-Path $Schema))
        {
            Write-Verbose "Saving Nuspec schema in a temporary location ($($env:TEMP)\nuspec.xsd)."
            $XsdPath = Join-Path $env:TEMP nuspec.xsd
            $Schema | Out-File $XsdPath -Encoding utf8
            $Schema = $XsdPath
        }
        Write-Verbose "Testing Nuspec manifest '$Path' against schema '$Schema'"
        Test-Xml -Path $Path -SchemaPath $Schema
    }
    catch
    {
        Write-Error $_
    }
}