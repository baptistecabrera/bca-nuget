function Get-NuspecSchema
{
    <#
        .SYNOPSIS
            Gets NuGet xsd schema for Nuspec file.
        .DESCRIPTION
            Gets NuGet xsd schema for Nuspec file from GitHub.
        .INPUTS
        .OUTPUTS
            System.String
            Returns a string containing the XSD content from Nuspec schema
        .EXAMPLE
            Get-NuspecSchema

            Description
            -----------
            This example connects to GitHub and retrieve xsd schema for Nuspec files.
        .NOTES
        .LINK
            https://docs.microsoft.com/en-us/nuget/reference/nuspec
        .LINK
            https://raw.githubusercontent.com/MyGet/NuGetPackages/master/NuSpec/tools/nuspec.xsd
    #>
    [CmdLetBinding()]
    param()
    try
    {
        Write-Verbose "Getting schema from 'https://raw.githubusercontent.com/MyGet/NuGetPackages/master/NuSpec/tools/nuspec.xsd'."
        (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/MyGet/NuGetPackages/master/NuSpec/tools/nuspec.xsd" -ContentType "application/xml; charset=utf-8").Content.Replace("`r`n", "").replace("`n", "")
    }
    catch { Write-Error $_ }
}