# Resolve-NuspecRepository
Type: Function
Module: [Bca.Nuget](../ReadMe.md)

Resolves a repository from an URI to be used in a Nuspec manifest.
## Description
Resolves a repository from an URI to be used in a Nuspec manifest.
## Syntax
```powershell
Resolve-NuspecRepository [-Uri] <uri> [<CommonParameters>]
```
## Examples
### Example 1
```powershell
Resolve-NuspecRepository -Uri "https://github.com/baptistecabrera/bca-nuget.git#master"
```
This example will return an object containing the URL to the repository 'https://github.com/baptistecabrera/bca-nuget.git' of type 'git' and specifying branch 'master'.
### Example 2
```powershell
Resolve-NuspecRepository -Uri "https://github.com/baptistecabrera/bca-nuget/tree/develop"
```
This example will return an object containing the URL to the repository 'https://github.com/baptistecabrera/bca-nuget.git' of type 'git' and specifying branch 'develop'.
### Example 3
```powershell
Resolve-NuspecRepository -Uri "https://github.com/baptistecabrera/bca-nuget/commit/301dfbdd6dc116e3426399acbebb28fe5561351e"
```
This example will return an object containing the URL to the repository 'https://github.com/baptistecabrera/bca-nuget.git' of type 'git' and specifying commit '301dfbdd6dc116e3426399acbebb28fe5561351e'.
## Parameters
### `-Uri`
An URI containing the repository URI.

| | |
|:-|:-|
|Type:|Uri|
|Aliases|Url|
|Position:|0|
|Required:|True|
|Accepts pipepline input:|False|

## Inputs
****

## Outputs
**System.Management.Automation.PSCustomObject**
Returns a PSCustomObject containing the repository properties.
## Related Links
- [Set-NuspecProperty](Set-NuspecProperty.md)
- [https://docs.microsoft.com/en-us/nuget/reference/nuspec#repository](https://docs.microsoft.com/en-us/nuget/reference/nuspec#repository)
