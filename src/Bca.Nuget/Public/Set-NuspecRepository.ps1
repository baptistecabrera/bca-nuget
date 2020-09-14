function Set-NuspecRepository
{
    <#
        .SYNOPSIS
            Sets the repository information in a Nuspec manifest.
        .DESCRIPTION
            Sets the repository information in a Nuspec manifest.
        .PARAMETER Uri
            An URI containing the URI of repository.
        .PARAMETER Type
            A string containing the type of repository.
        .Parameter Branch
            A string containing the branch.
        .PARAMETER commit
            A string containing the full commit SHA1.
        .PARAMETER Force
            A switch sepecifying whether or not to override repository if it already exists.
        .INPUTS
            System.Object
            Accepts an object containing the Name and Value as an input from the pipeline.
        .OUTPUTS
            System.Xml.XmlDocument
            Returns an XmlDocument containing the manifest.
        .NOTES
        .LINK
            Set-NuspecProperty
        .LINK
            https://docs.microsoft.com/en-us/nuget/reference/nuspec#repository
    #>
    [CmdLetBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("Url")]
        [uri] $Uri,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string] $Type,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string] $Branch,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ValidatePattern("^[a-f0-9]{40}$")]
        [string] $Commit,
        [Parameter(Mandatory = $true)]
        [xml] $Nuspec,
        [Parameter(Mandatory = $false)]
        [switch] $Force
    )

    try
    {
        $NameSpace = New-Object System.Xml.XmlNamespaceManager($Nuspec.NameTable)
        $NameSpace.AddNamespace("ns", $Nuspec.DocumentElement.xmlns)
        
        $Repository = $nuspec.SelectSingleNode("//ns:repository", $NameSpace)
        if (!$Repository -or $Force)
        {
            if ($Repository)
            {
                Write-Verbose "Removing existing repository node."
                $Nuspec.package.metadata.RemoveChild($Repository) | Out-Null
            }
            
            $Repository = $Nuspec.CreateElement("repository", $Nuspec.package.xmlns)

            $Repository.SetAttribute("url", $Uri.AbsoluteUri)
            if ($Type) { $Repository.SetAttribute("type", $Type.ToLower()) }
            if ($Branch) { $Repository.SetAttribute("branch", $Branch) }
            if ($Commit) { $Repository.SetAttribute("commit", $Commit) }
            $Nuspec.GetElementsByTagName("metadata").AppendChild($Repository) | Out-Null
        }
        else { Write-Warning "Repository already present ($($Repository.url)), use Force switch to override." }
        $Nuspec
    }
    catch
    {
        Write-Error $_
    }
}