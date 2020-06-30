function Add-NuspecDependency
{
    <#
        .SYNOPSIS
            Adds a dependency in a Nuspec manifest.
        .DESCRIPTION
            Adds a dependency in a Nuspec manifest.
            This CmdLet supports PowerShell module manifest file (psd1) 'RequiredModules' property as an input object.
        .PARAMETER Name
            A string containing the name of the dependency to be added.
        .PARAMETER Version
            A string containing the version of the dependency to be added.
        .PARAMETER InputObject
            An object containing the dependencies Name(s) and Version(s) to be added.
        .PARAMETER Nuspec
            An XmlDocument containing the Nuspec manifest.
        .INPUTS
            System.Object
            Accepts an object containing the Name/Id and Version as an input from the pipeline.
        .OUTPUTS
            System.Xml.XmlDocument
            Returns an XmlDocument containing the manifest.
        .EXAMPLE
            Add-NuspecDependency -Name "MyPackage" -Version "1.0.0" -Nuspec $NuspecManifest

            Description
            -----------
            This example will add a dependency on "MyPackage" minimum version "1.0.0" to the manifest, and return the XmlDocument.
        .EXAMPLE
            Add-NuspecDependency -Name "MyPackage" -Version "[1.0.0]" -Nuspec $NuspecManifest

            Description
            -----------
            This example will add a dependency on "MyPackage" exact version "1.0.0" to the manifest, and return the XmlDocument.
        .EXAMPLE
            Add-NuspecDependency -InputObject @{ id = "MyPackage" ; version = "1.0.0" } -Nuspec $NuspecManifest

            Description
            -----------
            This example will add a dependency on "MyPackage" version "1.0.0" to the manifest, and return the XmlDocument.
        .EXAMPLE
            Add-NuspecDependency -InputObject @( @{ id = "MyPackage" ; version = "1.0.0" } , @{ id = "MyPackage2" ; version = "2.0.0" } ) -Nuspec $NuspecManifest

            Description
            -----------
            This example will add a dependency on "MyPackage" version "1.0.0" and a dependency on "MyPackage2" version "2.0.0" to the manifest, and return the XmlDocument.
        .EXAMPLE
            Add-NuspecDependency -InputObject @( "MyModule1", @{ ModuleName = "MyModule2" ; ModuleVersion = "1.0.0" }, @{ ModuleName = "MyModule3" ; RequiredVersion = "1.0.0" } ) -Nuspec $NuspecManifest

            Description
            -----------
            This example will add a dependency on "MyModule1" implicitely on minimum version "0.0.0", a dependency on "MyModule2" version "1.0.0", and a dependency on "MyModule3" precise version "1.0.0" to the manifest, and return the XmlDocument.
        .EXAMPLE
            Add-NuspecDependency -InputObject (Import-PowerShellDataFile -Path .\MyModule.psd1).RequiredModules -Nuspec $NuspecManifest

            Description
            -----------
            This example will add dependencies contained in the property RequiredModules of the file MyModule.psd1, and return the XmlDocument.
        .NOTES
        .LINK
            https://docs.microsoft.com/en-us/nuget/consume-packages/dependency-resolution
        .LINK
            https://docs.microsoft.com/en-us/nuget/reference/package-versioning#version-ranges-and-wildcards
    #>
    [CmdLetBinding()]
    param(
        [Parameter(ParameterSetName = "FromValue", Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias("Id")]
        [string] $Name,
        [Parameter(ParameterSetName = "FromValue", Mandatory = $false)]
        [string] $Version = "0.0.0",
        [Parameter(ParameterSetName = "FromObject", Mandatory = $true, ValueFromPipeline = $true)]
        $InputObject,
        [Parameter(ParameterSetName = "FromValue", Mandatory = $true)]
        [Parameter(ParameterSetName = "FromObject", Mandatory = $true)]
        [xml] $Nuspec,
        [Parameter(ParameterSetName = "FromObject", Mandatory = $false)]
        [Parameter(ParameterSetName = "FromValue", Mandatory = $false)]
        $Match
    )

    $Dependencies = $Nuspec.GetElementsByTagName("dependencies")
    if (!$Dependencies.Name)
    {
        $FilesNode = $Nuspec.CreateElement("dependencies", $Nuspec.package.xmlns)
        $Nuspec.GetElementsByTagName("metadata").AppendChild($FilesNode) | Out-Null
    }

    switch ($PSCmdlet.ParameterSetName)
    {
        "FromValue"
        {
            if ($Name -match $Match)
            {
                $CurrentDependency = $Nuspec.package.metadata.dependencies.dependency | Where-Object { $_.id -eq $Name }
                if ($CurrentDependency) { Write-Warning "Dependency on '$Name' already exists with version '$($CurrentDependency.version)'." }
                else
                {
                    $Dependency = $Nuspec.CreateElement("dependency", $Nuspec.package.xmlns)
                    $Dependency.SetAttribute("id", $Name)
                    $Dependency.SetAttribute("version", $Version)
                    Write-Verbose "Adding a dependency on '$($Dependency.id)' (version '$($Dependency.version)')."
                    $Nuspec.GetElementsByTagName("dependencies").AppendChild($Dependency) | Out-Null
                }
            }
            else { Write-Warning "Dependency name '$Name' does not match the pattern '$Match', it will not be added." }
        }
        "FromObject"
        {
            $InputObject = $InputObject | ConvertTo-Json -Depth 100 | ConvertFrom-Json
            $InputObject | ForEach-Object {
                if ($_.GetType().Name -eq "PSCustomObject")
                {
                    if ($_.ModuleName -or $_.Name)
                    {
                        $Version = "0.0.0"
                        if ($_.ModuleName) { $Id = $_.ModuleName }
                        if ($_.Name) { $Id = $_.Name }
                        if ($_.Version) { $Version = $_.Version }
                        if ($_.ModuleVersion) { $Version = $_.ModuleVersion }
                        if ($_.RequiredVersion) { $Version = "[$($_.RequiredVersion)]" }
                        if ($_.MaximumVersion) { $Version = "(,$($_.MaximumVersion)]" }
                    }
                    elseif ($_.id)
                    {
                        $Id = $_.id
                        if (!$_.version) { $Version = "0.0.0" }
                        else { $Version = $_.version }
                    }
                    elseif ($_.value)
                    {
                        Add-NuspecDependency -InputObject $_.Value -Match $Match -Nuspec $Nuspec
                        break
                    }
                    else
                    {
                        Write-Error -Message "Unsupported object format for value for dependency '$_' ($($_.GetType().Name))." -Category InvalidData -CategoryActivity $MyInvocation.MyCommand -TargetName $Name -TargetType "Nuspec Property" -Exception InvalidDataException
                    }
                }
                elseif ($_.GetType().Name -eq "Object[]")
                {
                    $_ | ForEach-Object { Add-NuspecDependency -Name $_ -Version "0.0.0" -Match $Match -Nuspec $Nuspec }
                }
                elseif ($_.GetType().Name -eq "string")
                {
                    $_.Replace(" ", "").Split(",") | ForEach-Object { Add-NuspecDependency -Name $_ -Version "0.0.0" -Match $Match -Nuspec $Nuspec }
                }
                else
                {
                    Write-Verbose $_
                    $Id = $_
                    $Version = "0.0.0"
                }
                if ($Id) { Add-NuspecDependency -Name $Id -Version $Version -Match $Match -Nuspec $Nuspec }
            }
        }
    }
    $Nuspec
}