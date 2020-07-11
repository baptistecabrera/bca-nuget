function Set-NuspecLicense
{
    <#
        .SYNOPSIS
            Sets the license information in a Nuspec manifest.
        .DESCRIPTION
            Sets the license information in a Nuspec manifest.
        .PARAMETER Type
            A string containing the type of license (file or expression).
        .Parameter Value
            A string containing the reference of the license (package relative path to the license file, or SPDX license expression).
        .PARAMETER Nuspec
            An XmlDocument containing the Nuspec manifest.
        .PARAMETER Force
            A switch sepecifying whether or not to override license if it already exists.
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
            https://docs.microsoft.com/en-us/nuget/reference/nuspec#license
    #>
    [CmdLetBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("file", "expression")]
        [string] $Type,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $Value,
        [Parameter(Mandatory = $true)]
        [xml] $Nuspec,
        [Parameter(Mandatory = $false)]
        [switch] $Force
    )

    try
    {
        $License = $Nuspec.GetElementsByTagName("license")
        if (!$License.Name -or $Force)
        {
            if ($License.Name)
            {
                Write-Verbose "Removing existing license node."
                $Nuspec.package.metadata.RemoveChild($Nuspec.package.metadata.license) | Out-Null
            }
            $License = $Nuspec.CreateElement("license", $Nuspec.package.xmlns)

            switch ($Type)
            {
                "expression"
                {
                    if (!(Test-SpdxLicenseExpression -Expression $Value -FsfOrOsi -ErrorAction Continue)) { Write-Error -Message "Expression '$Value' is not a valid SPDX license expression." -Category InvalidData -CategoryActivity $MyInvocation.MyCommand -TargetName $Value -TargetType "SPDXLicenseExpression" -Exception InvalidDataException }
                    else
                    {
                        $License.SetAttribute("type", $Type.ToLower())
                        $License.set_InnerText($Value)
                        Write-Verbose "Setting '$Value' as the license expression."
                        $Nuspec.GetElementsByTagName("metadata").AppendChild($License) | Out-Null
                    }
                }
                "file"
                {
                    $File = Split-Path $Value -Leaf
                    if (($File -notlike "*.txt") -and ($File -notlike "*.md")) { Write-Error -Message "File '$Value' must be a text file (.txt) or a markdown file (.md)." -Category InvalidData -CategoryActivity $MyInvocation.MyCommand -TargetName $Value -TargetType "LicenseFile" -Exception InvalidDataException }
                    else
                    {
                        $License.SetAttribute("type", $Type.ToLower())
                        $License.set_InnerText($File)
                        Write-Verbose "Setting '$File' as the license file."
                        $Nuspec.GetElementsByTagName("metadata").AppendChild($License) | Out-Null

                        Write-Verbose "Adding a file node with source '$Value'."
                        $Nuspec = Add-NuspecFile -Source $Value -Nuspec $Nuspec
                    }
                }
            }

        }
        else { Write-Warning "License already present ($($License.InnerText)), use Force switch to override." }
        $Nuspec
    }
    catch
    {
        Write-Error $_
    }
}