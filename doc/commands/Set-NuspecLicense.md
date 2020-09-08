# Set-NuspecLicense
Type: Function
Module: [Bca.Nuget](../ReadMe.md)

Sets the license information in a Nuspec manifest.
## Description
Sets the license information in a Nuspec manifest.
## Syntax
```ps
Set-NuspecLicense [-Type] <string> [-Value] <string> [-Nuspec] <xml> [-Force] [<CommonParameters>]
```
## Parameters
### `-Type`
A string containing the type of license (file or expression).

| | |
|:-|:-|
|Type:|String|
|Position:|0|
|Required:|True|
|Accept pipeline input:|False|
|Validation (ValidValues):|file, expression|

### `-Value`
A string containing the reference of the license (package relative path to the license file, or SPDX license expression).

| | |
|:-|:-|
|Type:|String|
|Position:|1|
|Required:|True|
|Accept pipeline input:|False|

### `-Nuspec`
An XmlDocument containing the Nuspec manifest.

| | |
|:-|:-|
|Type:|XmlDocument|
|Position:|2|
|Required:|True|
|Accept pipeline input:|False|

### `-Force`
A switch sepecifying whether or not to override license and/or licenseUrl if it already exists.

| | |
|:-|:-|
|Type:|SwitchParameter|
|Default value:|False|
|Position:|Named|
|Required:|False|
|Accept pipeline input:|False|

## Inputs
**System.Object**
Accepts an object containing the Name and Value as an input from the pipeline.
## Outputs
**System.Xml.XmlDocument**
Returns an XmlDocument containing the manifest.
## Related Links
- [Set-NuspecProperty](Set-NuspecProperty.md)
