# Get-NuspecSchema
Type: Function
Module: [Bca.Nuget](../ReadMe.md)

Gets NuGet xsd schema for Nuspec file.
## Description
Gets NuGet xsd schema for Nuspec file from GitHub.
## Syntax
```powershell
Get-NuspecSchema [<CommonParameters>]
```
## Examples
### Example 1
```powershell
Get-NuspecSchema
```
This example connects to GitHub and retrieve xsd schema for Nuspec files.
## Parameters
## Inputs
****

## Outputs
**System.String**
Returns a string containing the XSD content from Nuspec schema
## Related Links
- [https://docs.microsoft.com/en-us/nuget/reference/nuspec](https://docs.microsoft.com/en-us/nuget/reference/nuspec)
- [https://raw.githubusercontent.com/MyGet/NuGetPackages/master/NuSpec/tools/nuspec.xsd](https://raw.githubusercontent.com/MyGet/NuGetPackages/master/NuSpec/tools/nuspec.xsd)
