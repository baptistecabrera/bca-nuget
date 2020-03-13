function Add-NuspecContentFile
{
    <#
        .SYNOPSIS
            Adds a content file in a Nuspec manifest.
        .DESCRIPTION
            Adds a content file in a Nuspec manifest.
        .PARAMETER Include
            A string containing path of the file or file pattern to be added, relative to the .nuspec file.
            The wildcard character * is allowed, and the double wildcard ** implies a recursive folder search.
        .PARAMETER Exclude
            A semicolon-delimited string containing a list of file or file patterns to exclude from the source.
            The wildcard character * is allowed, and the double wildcard ** implies a recursive folder search.
        .PARAMETER BuildAction
            A string containing the build action to assign to the content item for MSBuild.
        .PARAMETER CopyToOutput
            A switch specifying whether or not to copy content items to the build (or publish) output folder.
        .PARAMETER Flatten
            A switch specifying whether or not to copy content items to a single folder in the build output (specified), or to preserve the folder structure in the package (not specified). This flag only works when copyToOutput flag is specified.
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
        [Alias("i")]
        [string] $Include,
        [Parameter(Mandatory = $false)]
        [Alias("x")]
        [string] $Exclude,
        [Parameter(Mandatory = $false)]
        [ValidateSet("Content", "None", "EmbeddedResource", "Compile")]
        [Alias("b")]
        [string] $BuildAction = "Compile",
        [Parameter(Mandatory = $false)]
        [Alias("o")]
        [switch] $CopyToOutput,
        [Parameter(Mandatory = $false)]
        [Alias("f")]
        [switch] $Flatten,
        [Parameter(Mandatory = $true)]
        [xml] $Nuspec
    )

    try
    {
        $Files = $Nuspec.GetElementsByTagName("contentFiles")
        if (!$Files.Name)
        {
            $FilesNode = $Nuspec.CreateElement("contentFiles", $Nuspec.package.xmlns)
            $Nuspec.GetElementsByTagName("metadata").AppendChild($FilesNode) | Out-Null
        }

        Write-Verbose "Adding content file:"
        Write-Verbose "  Include`t`t`t`t`t`t`t`t`t:`t`t$Include"
        Write-Verbose "  Exclude`t`t`t`t`t`t`t`t`t:`t`t$Exclude"
        Write-Verbose "  Build Action`t`t`t`t:`t`t$BuilAction"
        Write-Verbose "  Copy to output`t`t:`t`t$CopyToOutput"
        Write-Verbose "  Flatten`t`t`t`t`t`t`t`t`t:`t`t$Flatten"
        $File = $Nuspec.CreateElement("file", $Nuspec.package.xmlns)
        $File.SetAttribute("include", $Include)
        if ($Exclude) { $File.SetAttribute("exclude", $Exclude) }
        $File.SetAttribute("buildAction", $BuildAction)
        if ($CopyToOutput)
        {
            $File.SetAttribute("copyToOutput", $CopyToOutput)
            $File.SetAttribute("flatten", $Flatten)
        }
        $Nuspec.GetElementsByTagName("contentFiles").AppendChild($File) | Out-Null

        $Nuspec
    }
    catch
    {
        Write-Error $_
    }
}