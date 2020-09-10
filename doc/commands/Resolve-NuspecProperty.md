# Resolve-NuspecProperty
Type: Function
Module: [Bca.Nuget](../ReadMe.md)

Resolves a property to be used in a Nuspec manifest.
## Description
Resolves a property that matches some mappings to be used in a Nuspec manifest.
This CmdLet supports most of PowerShell module manifest file (psd1) properties.
## Syntax
```ps
Resolve-NuspecProperty [-Name] <string> [[-Value] <Object>] [-AcceptChocolateyProperties] [<CommonParameters>]
```
## Examples
### Example 1
```ps
Resolve-NuspecProperty -Name "version" -Value "1.0.0"
```
This example will return the mapped property for "version" (which is "version") and the value specified.
### Example 2
```ps
Resolve-NuspecProperty -Name "RequiredModules" -Value @( "MyModule1", @{ ModuleName = "MyModule2" ; ModuleVersion = "1.0.0" }, @{ ModuleName = "MyModule3" ; RequiredVersion = "1.0.0" } )
```
This example will return the mapped property for "RequiredModules" (which is "dependencies") and the value specified.
### Example 3
```ps
Resolve-NuspecProperty -Name "CompanyName"
```
This example will return the mapped property for "CompanyName" (which is "owners").
## Parameters
### `-Name`
A string containing the name of the property to be resolved.

| | |
|:-|:-|
|Type:|String|
|Position:|0|
|Required:|True|
|Accepts pipepline input:|False|

### `-Value`
An object containing the value(s) of the property.

| | |
|:-|:-|
|Type:|Object|
|Position:|1|
|Required:|False|
|Accepts pipepline input:|False|

### `-AcceptChocolateyProperties`
A switch specifying whether or not to accept Chocolatey-specific properties.

| | |
|:-|:-|
|Type:|SwitchParameter|
|Default value:|False|
|Position:|Named|
|Required:|False|
|Accepts pipepline input:|False|

## Inputs
****

## Outputs
**System.Management.Automation.PSCustomObject**
Returns a PSCustomObject containing the name and value of the mapped property.
## Related Links
- [Set-NuspecProperty](Set-NuspecProperty.md)
- [https://docs.microsoft.com/en-us/nuget/reference/nuspec](https://docs.microsoft.com/en-us/nuget/reference/nuspec)
