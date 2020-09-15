# Add-NuspecContentFile
Type: Function
Module: [Bca.Nuget](../ReadMe.md)

Adds a content file in a Nuspec manifest.
## Description
Adds a content file in a Nuspec manifest.
## Syntax
```powershell
Add-NuspecContentFile [-Include] <string> [[-Exclude] <string>] [[-BuildAction] <string>] [-Nuspec] <xml> [-CopyToOutput] [-Flatten] [<CommonParameters>]
```
## Examples
### Example 1
```powershell
Add-NuspecFile -Source "bin\Debug\*.dll" -Destination "lib" -Nuspec $NuspecManifest
```
This example will add a node file with source "bin\Debug\*.dll" and destination "lib" to the manifest, and return the XmlDocument.
### Example 2
```powershell
Add-NuspecFile -Source "tools\**\*.*" -Exclude "**\*.log" -Nuspec $NuspecManifest
```
This example will add a node file with source "tools\**\*.*" excluding log files to the manifest, and return the XmlDocument.
## Parameters
### `-Include`
A string containing path of the file or file pattern to be added, relative to the .nuspec file.
The wildcard character * is allowed, and the double wildcard ** implies a recursive folder search.

| | |
|:-|:-|
|Type:|String|
|Aliases|i|
|Position:|0|
|Required:|True|
|Accepts pipepline input:|False|

### `-Exclude`
A semicolon-delimited string containing a list of file or file patterns to exclude from the source.
The wildcard character * is allowed, and the double wildcard ** implies a recursive folder search.

| | |
|:-|:-|
|Type:|String|
|Aliases|x|
|Position:|1|
|Required:|False|
|Accepts pipepline input:|False|

### `-BuildAction`
A string containing the build action to assign to the content item for MSBuild.

| | |
|:-|:-|
|Type:|String|
|Aliases|b|
|Default value:|Compile|
|Position:|2|
|Required:|False|
|Accepts pipepline input:|False|
|Validation (ValidValues):|Content, None, EmbeddedResource, Compile|

### `-CopyToOutput`
A switch specifying whether or not to copy content items to the build (or publish) output folder.

| | |
|:-|:-|
|Type:|SwitchParameter|
|Aliases|o|
|Default value:|False|
|Position:|Named|
|Required:|False|
|Accepts pipepline input:|False|

### `-Flatten`
A switch specifying whether or not to copy content items to a single folder in the build output (specified), or to preserve the folder structure in the package (not specified). This flag only works when copyToOutput flag is specified.

| | |
|:-|:-|
|Type:|SwitchParameter|
|Aliases|f|
|Default value:|False|
|Position:|Named|
|Required:|False|
|Accepts pipepline input:|False|

### `-Nuspec`
An XmlDocument containing the Nuspec manifest.

| | |
|:-|:-|
|Type:|XmlDocument|
|Position:|3|
|Required:|True|
|Accepts pipepline input:|False|

## Outputs
**System.Xml.XmlDocument**
Returns an XmlDocument containing the manifest.
