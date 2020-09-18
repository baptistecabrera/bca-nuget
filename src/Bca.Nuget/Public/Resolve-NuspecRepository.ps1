function Resolve-NuspecRepository
{
    <#
        .SYNOPSIS
            Resolves a repository from an URI to be used in a Nuspec manifest.
        .DESCRIPTION
            Resolves a repository from an URI to be used in a Nuspec manifest.
        .PARAMETER URI
            An URI containing the repository URI.
        .INPUTS
        .OUTPUTS
            System.Management.Automation.PSCustomObject
            Returns a PSCustomObject containing the repository properties.
        .EXAMPLE
            Resolve-NuspecRepository -Uri "https://github.com/baptistecabrera/bca-nuget.git#master"

            Description
            -----------
            This example will return an object containing the URL to the repository 'https://github.com/baptistecabrera/bca-nuget.git' of type 'git' and specifying branch 'master'.
        .EXAMPLE
            Resolve-NuspecRepository -Uri "https://github.com/baptistecabrera/bca-nuget/tree/develop"

            Description
            -----------
            This example will return an object containing the URL to the repository 'https://github.com/baptistecabrera/bca-nuget.git' of type 'git' and specifying branch 'develop'.
        .EXAMPLE
            Resolve-NuspecRepository -Uri "https://github.com/baptistecabrera/bca-nuget/commit/301dfbdd6dc116e3426399acbebb28fe5561351e"

            Description
            -----------
            This example will return an object containing the URL to the repository 'https://github.com/baptistecabrera/bca-nuget.git' of type 'git' and specifying commit '301dfbdd6dc116e3426399acbebb28fe5561351e'.
        .NOTES
        .LINK
            Set-NuspecProperty
        .LINK
            https://docs.microsoft.com/en-us/nuget/reference/nuspec#repository
    #>
    [CmdLetBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [Alias("Url")]
        [uri] $Uri
    )
    
    $Repository = New-Object -TypeName PSCustomObject

    if (($Uri.AbsoluteUri.Contains(".git")) -or ($Uri.Scheme -eq "git") -or ($Uri.AbsoluteUri.Contains("github.com")))
    {
        if ($Uri.AbsoluteUri.Contains("#"))
        {
            $Repository | Add-Member -MemberType NoteProperty -Name "Uri" -Value $Uri.AbsoluteUri.Split("#")[0] -PassThru | Out-Null
            $Repository | Add-Member -MemberType NoteProperty -Name "Branch" -Value $Uri.AbsoluteUri.Split("#")[1] -PassThru | Out-Null
        }
        else
        {
            if ($Uri.AbsoluteUri.Contains("/commit/")) { $Split = "/commit/" }
            elseif ($Uri.AbsoluteUri.Contains("/tree/")) { $Split = "/tree/" }
            elseif ($Uri.AbsoluteUri.Contains("/blob/")) { $Split = "/blob/" }
            else { $Split = "\.git" }
            $UriBase = ($Uri.AbsoluteUri -split $Split)[0]
            $UriPath = ($Uri.AbsoluteUri -split $Split)[1]
            
            if (!$UriBase.EndsWith(".git")) { $UriBase = ("{0}.git" -f $UriBase) }
            $Repository | Add-Member -MemberType NoteProperty -Name "Uri" -Value $UriBase -PassThru | Out-Null

            if ($UriPath)
            {
                if ($UriPath.Replace("/", "") -match "^[a-f0-9]{40}$") { $Repository | Add-Member -MemberType NoteProperty -Name "Commit" -Value $UriPath.Replace("/", "") -PassThru | Out-Null }
                else
                { $Repository | Add-Member -MemberType NoteProperty -Name "Branch" -Value $UriPath -PassThru | Out-Null }
            }
        }
        $Repository | Add-Member -MemberType NoteProperty -Name "Type" -Value "git" -PassThru | Out-Null
    }
    else { $Repository = $null }
    $Repository
}