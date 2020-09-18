# Get-NuspecProperty
Type: Function

Module: [Bca.Nuget](../ReadMe.md)

Gets a propertyand its value in a Nuspec manifest.
## Description
Gets a propertyand its value in a Nuspec manifest.
## Syntax
### FromXml
```powershell
Get-NuspecProperty -Name <string> -Nuspec <xml> [<CommonParameters>]
```
### FromFile
```powershell
Get-NuspecProperty -Name <string> -Path <string> [<CommonParameters>]
```
## Examples
### Example 1
```powershell
Get-NuspecProperty -Name "version"
```
This example will return the property for "version" and its value.
## Parameters
### `-Name`
A string containing the name of the property to be returned.

| | |
|:-|:-|
|Type:|String|
|Parameter sets:|FromXml, FromFile|
|Position:|Named|
|Required:|True|
|Accepts pipepline input:|False|

### `-Path`
A string containing the the full path of the Nuspec manifest file.

| | |
|:-|:-|
|Type:|String|
|Parameter sets:|FromFile|
|Position:|Named|
|Required:|True|
|Accepts pipepline input:|False|
|Validation (ScriptBlock):|` Test-Path $_ `|

### `-Nuspec`
An XmlDocument containing the Nuspec manifest.

| | |
|:-|:-|
|Type:|XmlDocument|
|Parameter sets:|FromXml|
|Position:|Named|
|Required:|True|
|Accepts pipepline input:|False|

## Inputs
****


## Outputs
**System.Management.Automation.PSCustomObject**

Returns a PSCustomObject containing the name and value of the mapped property.
## Related Links
- [Set-NuspecProperty](Set-NuspecProperty.md)
- [Resolve-NuspecProperty](Resolve-NuspecProperty.md)
- [https://docs.microsoft.com/en-us/nuget/reference/nuspec](https://docs.microsoft.com/en-us/nuget/reference/nuspec)
