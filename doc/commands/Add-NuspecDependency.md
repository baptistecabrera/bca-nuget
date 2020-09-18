# Add-NuspecDependency
Type: Function

Module: [Bca.Nuget](../ReadMe.md)

Adds a dependency in a Nuspec manifest.
## Description
Adds a dependency in a Nuspec manifest.
This CmdLet supports PowerShell module manifest file (psd1) 'RequiredModules' property as an input object.
## Syntax
### FromValue
```powershell
Add-NuspecDependency -Name <string> -Nuspec <xml> [-Version <string>] [-Match <Object>] [<CommonParameters>]
```
### FromObject
```powershell
Add-NuspecDependency -InputObject <Object> -Nuspec <xml> [-Match <Object>] [<CommonParameters>]
```
## Examples
### Example 1
```powershell
Add-NuspecDependency -Name "MyPackage" -Version "1.0.0" -Nuspec $NuspecManifest
```
This example will add a dependency on "MyPackage" minimum version "1.0.0" to the manifest, and return the XmlDocument.
### Example 2
```powershell
Add-NuspecDependency -Name "MyPackage" -Version "[1.0.0]" -Nuspec $NuspecManifest
```
This example will add a dependency on "MyPackage" exact version "1.0.0" to the manifest, and return the XmlDocument.
### Example 3
```powershell
Add-NuspecDependency -InputObject @{ id = "MyPackage" ; version = "1.0.0" } -Nuspec $NuspecManifest
```
This example will add a dependency on "MyPackage" version "1.0.0" to the manifest, and return the XmlDocument.
### Example 4
```powershell
Add-NuspecDependency -InputObject @( @{ id = "MyPackage" ; version = "1.0.0" } , @{ id = "MyPackage2" ; version = "2.0.0" } ) -Nuspec $NuspecManifest
```
This example will add a dependency on "MyPackage" version "1.0.0" and a dependency on "MyPackage2" version "2.0.0" to the manifest, and return the XmlDocument.
### Example 5
```powershell
Add-NuspecDependency -InputObject @( "MyModule1", @{ ModuleName = "MyModule2" ; ModuleVersion = "1.0.0" }, @{ ModuleName = "MyModule3" ; RequiredVersion = "1.0.0" } ) -Nuspec $NuspecManifest
```
This example will add a dependency on "MyModule1" implicitely on minimum version "0.0.0", a dependency on "MyModule2" version "1.0.0", and a dependency on "MyModule3" precise version "1.0.0" to the manifest, and return the XmlDocument.
### Example 6
```powershell
Add-NuspecDependency -InputObject (Import-PowerShellDataFile -Path .\MyModule.psd1).RequiredModules -Nuspec $NuspecManifest
```
This example will add dependencies contained in the property RequiredModules of the file MyModule.psd1, and return the XmlDocument.
## Parameters
### `-Name`
A string containing the name of the dependency to be added.

| | |
|:-|:-|
|Type:|String|
|Aliases|Id|
|Parameter sets:|FromValue|
|Position:|Named|
|Required:|True|
|Accepts pipepline input:|False|

### `-Version`
A string containing the version of the dependency to be added.

| | |
|:-|:-|
|Type:|String|
|Default value:|0.0.0|
|Parameter sets:|FromValue|
|Position:|Named|
|Required:|False|
|Accepts pipepline input:|False|

### `-InputObject`
An object containing the dependencies Name(s) and Version(s) to be added.

| | |
|:-|:-|
|Type:|Object|
|Parameter sets:|FromObject|
|Position:|Named|
|Required:|True|
|Accepts pipepline input:|True|

### `-Nuspec`
An XmlDocument containing the Nuspec manifest.

| | |
|:-|:-|
|Type:|XmlDocument|
|Parameter sets:|FromObject, FromValue|
|Position:|Named|
|Required:|True|
|Accepts pipepline input:|False|

### `-Match`

| | |
|:-|:-|
|Type:|Object|
|Parameter sets:|FromValue, FromObject|
|Position:|Named|
|Required:|False|
|Accepts pipepline input:|False|

## Inputs
**System.Object**

Accepts an object containing the Name/Id and Version as an input from the pipeline.
## Outputs
**System.Xml.XmlDocument**

Returns an XmlDocument containing the manifest.
## Related Links
- [https://docs.microsoft.com/en-us/nuget/consume-packages/dependency-resolution](https://docs.microsoft.com/en-us/nuget/consume-packages/dependency-resolution)
- [https://docs.microsoft.com/en-us/nuget/reference/package-versioning#version-ranges-and-wildcards](https://docs.microsoft.com/en-us/nuget/reference/package-versioning#version-ranges-and-wildcards)
