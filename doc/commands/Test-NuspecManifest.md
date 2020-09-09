# Test-NuspecManifest
Type: Function
Module: [Bca.Nuget](../ReadMe.md)

Tests a Nuspec manifest.
## Description
Tests a Nuspec manifest against an xsd schema.
## Syntax
### FromFile
```ps
Test-NuspecManifest -Path <string> [-Schema <string>] [<CommonParameters>]
```
### FromXml
```ps
Test-NuspecManifest -Nuspec <xml> [-Schema <string>] [<CommonParameters>]
```
## Examples
### Example 1
```ps
Test-NuspecManifest -Path .\package.nuspec -Schema .\nuspec.xsd
```
This example will test the file 'package.nuspec' against the schema 'nuspec.xsd'.
### Example 2
```ps
Test-NuspecManifest -Nuspec $NuspecContent
```
This example will test the xml document contained in a variable against the default Nuspec schema.
## Parameters
### `-Path`
A string containing the full path to the Nuspec manifest file.

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

### `-Schema`
A string containing either the content or the full path of the xsd schema.
Will use 'Get-NuspecSchema' if omitted.

| | |
|:-|:-|
|Type:|String|
|Default value:|(Get-NuspecSchema)|
|Parameter sets:|FromXml, FromFile|
|Position:|Named|
|Required:|False|
|Accepts pipepline input:|False|

## Inputs
****

## Outputs
**System.Boolean**
Returns a boolean specifying whether or not the manifest is conform to teh schema.
## Related Links
- [Get-NuspecSchema](Get-NuspecSchema.md)
- [https://docs.microsoft.com/en-us/nuget/reference/nuspec](https://docs.microsoft.com/en-us/nuget/reference/nuspec)
- [https://raw.githubusercontent.com/MyGet/NuGetPackages/master/NuSpec/tools/nuspec.xsd](https://raw.githubusercontent.com/MyGet/NuGetPackages/master/NuSpec/tools/nuspec.xsd)
