# Add-NuspecFile
Type: Function
Module: [Bca.Nuget](../ReadMe.md)

Adds a file in a Nuspec manifest.
## Description
Adds a file in a Nuspec manifest.
## Syntax
```powershell
Add-NuspecFile [-Source] <string> [[-Destination] <string>] [[-Exclude] <string>] [-Nuspec] <xml> [<CommonParameters>]
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
### `-Source`
A string containing the source of the file or file pattern to be added, relative to the .nuspec file.
The wildcard character * is allowed, and the double wildcard ** implies a recursive folder search.

| | |
|:-|:-|
|Type:|String|
|Aliases|src, s|
|Position:|0|
|Required:|True|
|Accepts pipepline input:|False|

### `-Destination`
A string containing the destination of the file to be added.

| | |
|:-|:-|
|Type:|String|
|Aliases|Target, d, t|
|Position:|1|
|Required:|False|
|Accepts pipepline input:|False|

### `-Exclude`
A semicolon-delimited string containing a list of file or file patterns to exclude from the source.
The wildcard character * is allowed, and the double wildcard ** implies a recursive folder search.

| | |
|:-|:-|
|Type:|String|
|Aliases|x|
|Position:|2|
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
