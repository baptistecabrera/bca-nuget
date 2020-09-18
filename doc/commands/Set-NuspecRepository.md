# Set-NuspecRepository
Type: Function

Module: [Bca.Nuget](../ReadMe.md)

Sets the repository information in a Nuspec manifest.
## Description
Sets the repository information in a Nuspec manifest.
## Syntax
```powershell
Set-NuspecRepository [-Uri] <uri> [[-Type] <string>] [[-Branch] <string>] [[-Commit] <string>] [-Nuspec] <xml> [-Force] [<CommonParameters>]
```
## Parameters
### `-Uri`
An URI containing the URI of repository.

| | |
|:-|:-|
|Type:|Uri|
|Aliases|Url|
|Position:|0|
|Required:|True|
|Accepts pipepline input:|True (by property name)|

### `-Type`
A string containing the type of repository.

| | |
|:-|:-|
|Type:|String|
|Position:|1|
|Required:|False|
|Accepts pipepline input:|True (by property name)|

### `-Branch`
A string containing the branch.

| | |
|:-|:-|
|Type:|String|
|Position:|2|
|Required:|False|
|Accepts pipepline input:|True (by property name)|

### `-Commit`
A string containing the full commit SHA1.

| | |
|:-|:-|
|Type:|String|
|Position:|3|
|Required:|False|
|Accepts pipepline input:|True (by property name)|
|Validation (Options):|IgnoreCase|
|Validation (RegexPattern):|`^[a-f0-9]{40}$`|

### `-Nuspec`

| | |
|:-|:-|
|Type:|XmlDocument|
|Position:|4|
|Required:|True|
|Accepts pipepline input:|False|

### `-Force`
A switch sepecifying whether or not to override repository if it already exists.

| | |
|:-|:-|
|Type:|SwitchParameter|
|Default value:|False|
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
- [Set-NuspecProperty](Set-NuspecProperty.md)
- [https://docs.microsoft.com/en-us/nuget/reference/nuspec#repository](https://docs.microsoft.com/en-us/nuget/reference/nuspec#repository)
