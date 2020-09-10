function Save-NuspecManifest
{
    <#
        .SYNOPSIS
            Saves a Nuspec manifest.
        .DESCRIPTION
            Saves a Nuspec manifest to a file.
        .PARAMETER Path
            A string containing the the full path to save the Nuspec manifest file.
        .PARAMETER Nuspec
            An XmlDocument containing the Nuspec manifest.
        .INPUTS
            System.Xml.XmlDocument
            Accepts an XmlDocument containing the manifest.
        .OUTPUTS
            System.String
            Returns a string containing the path to the manifest file
        .EXAMPLE
            Save-NuspecManifest -Nuspec $Nuspec -Path .\mypackage.nuspec

            Description
            -----------
            This example will save the Nuspec manifest in the file mypackage.nuscpec.
        .EXAMPLE
            Import-PowerShellDataFile .\MyModule.psd1 | ConvertTo-NuspecManifest | Save-NuspecManifest -Path .\mymodule.nuspec

            Description
            -----------
            This example will save the Nuspec manifest in the file mypackage.nuscpec.
        .NOTES
        .LINK
            ConvertTo-NuspecManifest
        .LINK
            https://docs.microsoft.com/en-us/nuget/reference/nuspec
    #>
    [CmdLetBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript( {
            if ((Test-Path $_))
            {
                $Item = Get-Item $_
                if ($Item.PSIsContainer) { $true }
                else
                {
                    if ($Item.Extension -eq ".nuspec") { $true }
                    else { throw "Could not validate path '$_' because it is not a Nuspec file." }
                }
            }
            else { $true}
        } )]
        [string] $Path,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [xml] $Nuspec
    )

    try
    {
        Write-Verbose "coucou"
        $NuspecId = (Get-NuspecProperty -Name id -Nuspec $Nuspec).Value
        if ((Test-Path $Path))
        {
            $Item = Get-Item $Path
            if ($Item.PSIsContainer) { $Path = Join-Path $Item.FullName ("{0}.nuspec" -f $NuspecId) }
            else { $Path = $Item.FullName }
        }
        elseif ($Path.EndsWith(".nuspec"))
        {
            $Directory = Split-Path $Path -Parent
            if (!(Test-Path $Directory)) { $Directory = New-Item -Path (Split-Path $Path -Parent) -ItemType Directory -Force | Out-Null }
            else { $Directory = Get-Item $Directory }
            $Path = Join-Path $Directory.FullName (Split-Path $Path -Leaf)
        }
        else
        { 
            $Directory = New-Item -Path $Path -ItemType Directory -Force
            $Path = Join-Path $Directory.FullName ("{0}.nuspec" -f $NuspecId)
        }
        Write-Verbose $Path
        $Nuspec.Save($Path) | Out-Null
        (Get-Item $Path).FullName
    }
    catch
    {
        Write-Error $_
    }


}