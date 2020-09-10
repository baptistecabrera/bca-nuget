function Resolve-NuspecProperty
{
    <#
        .SYNOPSIS
            Resolves a property to be used in a Nuspec manifest.
        .DESCRIPTION
            Resolves a property that matches some mappings to be used in a Nuspec manifest.
            This CmdLet supports most of PowerShell module manifest file (psd1) properties.
        .PARAMETER Name
            A string containing the name of the property to be resolved.
        .PARAMETER Value
            An object containing the value(s) of the property.
        .PARAMETER AcceptChocolateyProperties
            A switch specifying whether or not to accept Chocolatey-specific properties.
        .INPUTS
        .OUTPUTS
            System.Management.Automation.PSCustomObject
            Returns a PSCustomObject containing the name and value of the mapped property.
        .EXAMPLE
            Resolve-NuspecProperty -Name "version" -Value "1.0.0"

            Description
            -----------
            This example will return the mapped property for "version" (which is "version") and the value specified.
        .EXAMPLE
            Resolve-NuspecProperty -Name "RequiredModules" -Value @( "MyModule1", @{ ModuleName = "MyModule2" ; ModuleVersion = "1.0.0" }, @{ ModuleName = "MyModule3" ; RequiredVersion = "1.0.0" } )

            Description
            -----------
            This example will return the mapped property for "RequiredModules" (which is "dependencies") and the value specified.
        .EXAMPLE
            Resolve-NuspecProperty -Name "CompanyName"

            Description
            -----------
            This example will return the mapped property for "CompanyName" (which is "owners").
        .NOTES
        .LINK
            Set-NuspecProperty
        .LINK
            https://docs.microsoft.com/en-us/nuget/reference/nuspec
    #>
    [CmdLetBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,
        [Parameter(Mandatory = $false)]
        $Value,
        [Parameter(Mandatory = $false)]
        [switch] $AcceptChocolateyProperties
    )
    
    $ResolvedProperty = New-Object -TypeName PSCustomObject
    switch -Regex ($Name)
    {
        "description"
        {
            $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Name" -Value "description" -PassThru | Out-Null
            $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Value" -Value $Value -PassThru | Out-Null
        }
        "^summary$"
        {
            $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Name" -Value "summary" -PassThru | Out-Null
            $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Value" -Value $Value -PassThru | Out-Null
        }
        "^version$|ModuleVersion"
        {
            switch -Regex ($Value.GetType().Name)
            {
                "version" { $Value = $Value.ToString() }
                "object" { $Value = "$($Value.Major).$($Value.Minor).$($Value.Build)" }
            }
            $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Name" -Value "version" -PassThru | Out-Null
            $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Value" -Value $Value -PassThru | Out-Null
        }
        "Prerelease"
        {
            $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Name" -Value "Prerelease" -PassThru | Out-Null
            $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Value" -Value $Value -PassThru | Out-Null
        }
        "^name$|^id$|RootModule|ModuleToProcess"
        {
            $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Name" -Value "id" -PassThru | Out-Null
            if ((($Name -eq "RootModule") -or ($Name -eq "ModuleToProcess")) -and ($Value)) { $Value = $Value.Replace(".psm1", "") }
            $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Value" -Value $Value -PassThru | Out-Null
        }
        "^title$"
        {
            $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Name" -Value "title" -PassThru | Out-Null
            $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Value" -Value $Value -PassThru | Out-Null
        }
        "^owners$|CompanyName"
        {
            $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Name" -Value "owners" -PassThru | Out-Null
            $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Value" -Value $Value -PassThru | Out-Null
        }
        "^authors$|Author"
        {
            $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Name" -Value "authors" -PassThru | Out-Null
            $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Value" -Value $Value -PassThru | Out-Null
        }
        "Copyright"
        {
            $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Name" -Value "copyright" -PassThru | Out-Null
            $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Value" -Value $Value -PassThru | Out-Null
        }
        "projectUrl|ProjectUri"
        {
            $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Name" -Value "projectUrl" -PassThru | Out-Null
            $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Value" -Value $Value -PassThru | Out-Null
        }
        "licenseUrl|LicenseUri"
        {
            $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Name" -Value "licenseUrl" -PassThru | Out-Null
            $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Value" -Value $Value -PassThru | Out-Null
        }
        "^license$"
        {
            $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Name" -Value "license" -PassThru | Out-Null
            $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Value" -Value $Value -PassThru | Out-Null
        }
        "iconUrl|IconUri"
        {
            $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Name" -Value "iconUrl" -PassThru | Out-Null
            $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Value" -Value $Value -PassThru | Out-Null
        }
        "dependencies|RequiredModules|RequiredScripts"
        {
            $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Name" -Value "dependencies" -PassThru | Out-Null
            $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Value" -Value $Value -PassThru | Out-Null
            
        }
        "tags"
        {
            if ($Value.GetType().Name -eq "string") { $Value = $Value.Split(",") -join " " }
            else { $Value = $Value | Select-Object -Unique }
            $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Name" -Value "tags" -PassThru | Out-Null
            $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Value" -Value $($Value.Split(" ") -join " ") -PassThru | Out-Null
        }
        "releaseNotes"
        {
            $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Name" -Value "releaseNotes" -PassThru | Out-Null
            if ($Value -like "*.md") { $Value = Get-Content $Value }
            $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Value" -Value ($Value -join "`r`n") -PassThru | Out-Null   
        }
        "^docsUrl$|^mailingListUrl$|^bugTrackerUrl$|^packageSourceUrl$|^projectSourceUrl$"
        {
            if ($AcceptChocolateyProperties)
            {
                $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Name" -Value $Name -PassThru | Out-Null
                $ResolvedProperty | Add-Member -MemberType NoteProperty -Name "Value" -Value $Value -PassThru | Out-Null
            }
            else { Write-Warning "Property '$Name' does not match any mapped Nuspec property." }    
        }
        default { Write-Warning "Property '$Name' does not match any mapped Nuspec property." }
    }
    if ($ResolvedProperty.Name)
    { 
        Write-Verbose "Property '$Name' resolved to '$($ResolvedProperty.Name)'."
        if ($ResolvedProperty.Value) { Write-Verbose "Value returned for this property is '$($ResolvedProperty.Value)' ($($ResolvedProperty.Value.GetType().Name))." }
    }
    else { $ResolvedProperty = $null }
    $ResolvedProperty
}