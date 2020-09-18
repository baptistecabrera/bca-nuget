# Set-NuspecProperty
Type: Function

Module: [Bca.Nuget](../ReadMe.md)

Sets a property value in a Nuspec manifest.
## Description
Sets a property value in a Nuspec manifest.
## Syntax
### FromXml
```powershell
Set-NuspecProperty -Name <string> -Value <Object> -Nuspec <xml> [-AcceptChocolateyProperties] [-Force] [<CommonParameters>]
```
### FromFile
```powershell
Set-NuspecProperty -Name <string> -Value <Object> -Path <string> [-AcceptChocolateyProperties] [-Force] [<CommonParameters>]
```
## Examples
### Example 1
```powershell
Set-NuspecProperty -Name "version" -Value "1.0.0" -Path .\package.nuspec
```
This example will set the property "version" value to "1.0.0", save the file, and return the manifest XmlDocument.
### Example 2
```powershell
Set-NuspecProperty -Name "dependencies" -Value @( "MyModule1", @{ ModuleName = "MyModule2" ; ModuleVersion = "1.0.0" }, @{ ModuleName = "MyModule3" ; RequiredVersion = "1.0.0" } ) -Nuspec $NuspecManifest
```
This example set multiple "dependency" properties under the property "dependencies" for each value in value and return the manifest XmlDocument.
### Example 3
```powershell
Resolve-NuspecProperty -Name "name" -Value "value" | Set-NuspecProperty -Nuspec $NuspecManifest
```
This example will resolve the property "name" and sets its value, then return the manifest XmlDocument.
## Parameters
### `-Name`
A string containing the name of the property to be set.

| | |
|:-|:-|
|Type:|String|
|Parameter sets:|FromXml, FromFile|
|Position:|Named|
|Required:|True|
|Accepts pipepline input:|True (by property name)|

### `-Value`
An object containing the value(s) of the property.

| | |
|:-|:-|
|Type:|Object|
|Parameter sets:|FromXml, FromFile|
|Position:|Named|
|Required:|True|
|Accepts pipepline input:|True (by property name)|

### `-Path`
A string containing the the full path of the Nuspec manifest file.
The file will be saved after the property is set.

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

### `-AcceptChocolateyProperties`
A switch specifying whether or not to accept Chocolatey-specific properties.

| | |
|:-|:-|
|Type:|SwitchParameter|
|Default value:|False|
|Parameter sets:|FromXml, FromFile|
|Position:|Named|
|Required:|False|
|Accepts pipepline input:|False|

### `-Force`
A switch specifying whether or not to override teh value.

| | |
|:-|:-|
|Type:|SwitchParameter|
|Default value:|False|
|Parameter sets:|FromXml, FromFile|
|Position:|Named|
|Required:|False|
|Accepts pipepline input:|False|

## Inputs
**System.Object**

Accepts an object containing the Name and Value as an input from the pipeline.
## Outputs
**System.Xml.XmlDocument**

Returns an XmlDocument containing the manifest.
## Related Links
- [Resolve-NuspecProperty](Resolve-NuspecProperty.md)
- [Add-NuspecDependency](Add-NuspecDependency.md)
- [https://docs.microsoft.com/en-us/nuget/reference/nuspec](https://docs.microsoft.com/en-us/nuget/reference/nuspec)
