# ConvertTo-NuspecManifest
Type: Function
Module: [Bca.Nuget](../ReadMe.md)

Converts an object to a NuspecManifest.
## Description
Converts an object to a NuspecManifest.
## Syntax
```ps
ConvertTo-NuspecManifest [-InputObject] <Object> [[-DependencyMatch] <Object>] [-AcceptChocolateyProperties] [<CommonParameters>]
```
## Examples
### Example 1
```ps
ConvertTo-NuspecManifest -InputObject ((Get-Content .\package.json) | Convert-From-Json)
```
This example will get the content of "package.json" and map properties to create a Nuspec manifest.
### Example 2
```ps
Import-PowerShellDataFile -Path .\MyModule.psd1 | ConvertTo-NuspecManifest
```
This example will import the PowerShell module manifest "MyModule.psd1" and map properties to create a Nuspec manifest.
Import-PowerShellDataFile only works with PowerShell v5+, for v4 use Import-LocalizedData.
### Example 3
```ps
Get-Module MyModule | ConvertTo-NuspecManifest
```
This example will get the PowerShell module MyModule and map properties to create a Nuspec manifest.
### Example 4
```ps
Test-ScriptFileInfo C:\MyScript.ps1 | ConvertTo-NuspecManifest
```
This example will get the script file info of the PowerShell script MyScript.ps1 and map properties to create a Nuspec manifest.
## Parameters
### `-InputObject`
An object containing the specifications to be converted into a Nuspec manifest.

| | |
|:-|:-|
|Type:|Object|
|Position:|0|
|Required:|True|
|Accept pipeline input:|True|
|Validation (ScriptBlock):|` try { $_ | ConvertTo-Json | ConvertFrom-Json $true } catch { throw "Could not convert input object type '$($InputObject.GetType().Name)'." } `|

### `-AcceptChocolateyProperties`
A switch specifying whether or not to accept Chocolatey-specific properties.

| | |
|:-|:-|
|Type:|SwitchParameter|
|Default value:|False|
|Position:|Named|
|Required:|False|
|Accept pipeline input:|False|

### `-DependencyMatch`
A string containing a regular expression to match the dependencies against.
If used and a dependency does not match, it will be excluded fro the resulting nuspec manifest.

| | |
|:-|:-|
|Type:|Object|
|Position:|1|
|Required:|False|
|Accept pipeline input:|False|

## Inputs
**System.Object**
Accepts an object representing data that can be mapped to Nuspec properties and converted to a Nuspec manifest.
## Outputs
**System.Xml.XmlDocument**
Returns an XmlDocument containing the manifest.
## Notes
This version supports mostly PowerShell Module amd Scripts File Info properties.
## Related Links
- Get-NuspecProperty
- Set-NuspecProperty
- Resolve-NuspecProperty
