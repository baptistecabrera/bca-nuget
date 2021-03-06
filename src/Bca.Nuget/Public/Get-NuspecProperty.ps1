function Get-NuspecProperty
{
    <#
        .SYNOPSIS
            Gets a propertyand its value in a Nuspec manifest.
        .DESCRIPTION
            Gets a propertyand its value in a Nuspec manifest.
        .PARAMETER Name
            A string containing the name of the property to be returned.
        .PARAMETER Path
            A string containing the the full path of the Nuspec manifest file.
        .PARAMETER Nuspec
            An XmlDocument containing the Nuspec manifest.
        .INPUTS
        .OUTPUTS
            System.Management.Automation.PSCustomObject
            Returns a PSCustomObject containing the name and value of the mapped property.
        .EXAMPLE
            Get-NuspecProperty -Name "version"

            Description
            -----------
            This example will return the property for "version" and its value.
        .NOTES
        .LINK
            Set-NuspecProperty
        .LINK
            Resolve-NuspecProperty
        .LINK
            https://docs.microsoft.com/en-us/nuget/reference/nuspec
    #>
    [CmdLetBinding()]
    param(
        [Parameter(ParameterSetName = "FromFile", Mandatory = $true)]
        [Parameter(ParameterSetName = "FromXml", Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,
        [Parameter(ParameterSetName = "FromFile", Mandatory = $true)]
        [ValidateScript( { Test-Path $_ } )]
        [string] $Path,
        [Parameter(ParameterSetName = "FromXml", Mandatory = $true)]
        [xml] $Nuspec
    )

    $Property = New-Object -TypeName PSCustomObject
    if ($PSCmdlet.ParameterSetName -eq "FromFile") { [xml] $Nuspec = Get-Content $Path }
    
    $NameSpace = New-Object System.Xml.XmlNamespaceManager($Nuspec.NameTable)
    $NameSpace.AddNamespace("ns", $Nuspec.DocumentElement.xmlns)
    
    $PropertyNode = $nuspec.SelectSingleNode("//ns:$($Name)", $NameSpace)
    if ($PropertyNode)
    {
        $ChildName = ($PropertyNode | Get-Member -MemberType Property).Name
        $Property | Add-Member -MemberType NoteProperty -Name "Name" -Value $PropertyNode.ToString() -PassThru | Out-Null
        $Property | Add-Member -MemberType NoteProperty -Name "Value" -Value $PropertyNode.$ChildName -PassThru | Out-Null
    }
    $Property
}