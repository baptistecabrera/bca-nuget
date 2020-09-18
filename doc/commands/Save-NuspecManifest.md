# Save-NuspecManifest
Type: Function

Module: [Bca.Nuget](../ReadMe.md)

Saves a Nuspec manifest.
## Description
Saves a Nuspec manifest to a file.
## Syntax
```powershell
Save-NuspecManifest [-Path] <string> [-Nuspec] <xml> [<CommonParameters>]
```
## Examples
### Example 1
```powershell
Save-NuspecManifest -Nuspec $Nuspec -Path .\mypackage.nuspec
```
This example will save the Nuspec manifest in the file mypackage.nuscpec.
### Example 2
```powershell
Import-PowerShellDataFile .\MyModule.psd1 | ConvertTo-NuspecManifest | Save-NuspecManifest -Path .\mymodule.nuspec
```
This example will save the Nuspec manifest in the file mypackage.nuscpec.
## Parameters
### `-Path`
A string containing the the full path to save the Nuspec manifest file.

| | |
|:-|:-|
|Type:|String|
|Position:|0|
|Required:|True|
|Accepts pipepline input:|False|
|Validation (ScriptBlock):|` if ((Test-Path $_)) { $Item = Get-Item $_ if ($Item.PSIsContainer) { $true } else { if ($Item.Extension -eq ".nuspec") { $true } else { throw "Could not validate path '$_' because it is not a Nuspec file." } } } else { $true} `|

### `-Nuspec`
An XmlDocument containing the Nuspec manifest.

| | |
|:-|:-|
|Type:|XmlDocument|
|Position:|1|
|Required:|True|
|Accepts pipepline input:|True|

## Inputs
**System.Xml.XmlDocument**

Accepts an XmlDocument containing the manifest.
## Outputs
**System.String**

Returns a string containing the path to the manifest file
## Related Links
- [ConvertTo-NuspecManifest](ConvertTo-NuspecManifest.md)
- [https://docs.microsoft.com/en-us/nuget/reference/nuspec](https://docs.microsoft.com/en-us/nuget/reference/nuspec)
