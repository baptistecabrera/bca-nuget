function Add-NuspecFile
{
    <#
        .SYNOPSIS
            Adds a file in a Nuspec manifest.
        .DESCRIPTION
            Adds a file in a Nuspec manifest.
        .PARAMETER Source
            A string containing the source of the file or file pattern to be added, relative to the .nuspec file.
            The wildcard character * is allowed, and the double wildcard ** implies a recursive folder search.
        .PARAMETER Destination
            A string containing the destination of the file to be added.
        .PARAMETER Exclude
            A semicolon-delimited string containing a list of file or file patterns to exclude from the source.
            The wildcard character * is allowed, and the double wildcard ** implies a recursive folder search.
        .PARAMETER Nuspec
            An XmlDocument containing the Nuspec manifest.
        .OUTPUTS
            System.Xml.XmlDocument
            Returns an XmlDocument containing the manifest.
        .EXAMPLE
            Add-NuspecFile -Source "bin\Debug\*.dll" -Destination "lib" -Nuspec $NuspecManifest

            Description
            -----------
            This example will add a node file with source "bin\Debug\*.dll" and destination "lib" to the manifest, and return the XmlDocument.
        .EXAMPLE
            Add-NuspecFile -Source "tools\**\*.*" -Exclude "**\*.log" -Nuspec $NuspecManifest

            Description
            -----------
            This example will add a node file with source "tools\**\*.*" excluding log files to the manifest, and return the XmlDocument.
        .NOTES
        .LINK
            https://docs.microsoft.com/en-us/nuget/reference/nuspec
    #>
    [CmdLetBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias("src", "s")]
        [string] $Source,
        [Parameter(Mandatory = $false)]
        [Alias("Target", "d", "t")]
        [string] $Destination = "",
        [Parameter(Mandatory = $false)]
        [Alias("x")]
        [string] $Exclude = "",
        [Parameter(Mandatory = $true)]
        [xml] $Nuspec
    )

    try
    {
        $Files = $Nuspec.GetElementsByTagName("files")
        if (!$Files.Name)
        {
            $FilesNode = $Nuspec.CreateElement("files", $Nuspec.package.xmlns)
            $Nuspec.GetElementsByTagName("package").AppendChild($FilesNode) | Out-Null
        }

        Write-Verbose "Adding file:"
        Write-Verbose "  Source`t`t`t`t`t`t:`t`t$Source"
        Write-Verbose "  Destination`t:`t`t$Destination"
        Write-Verbose "  Exclusions`t`t:`t`t$Exclude"
        $File = $Nuspec.CreateElement("file", $Nuspec.package.xmlns)
        $File.SetAttribute("src", $Source)
        $File.SetAttribute("target", $Destination)
        if ($Exclude) { $File.SetAttribute("exclude", $Exclude) }
        $Nuspec.GetElementsByTagName("files").AppendChild($File) | Out-Null

        $Nuspec
    }
    catch
    {
        Write-Error $_
    }
}