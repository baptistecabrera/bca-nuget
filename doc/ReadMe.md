# Bca.Nuget `0.0.8`
Tags: `NuGet` `Package` `PackageManager` `Packaging`

PowerShell module to create and manage NuGet packages.

## Commands
- [Add-NuspecContentFile](commands/Add-NuspecContentFile.md)
- [Add-NuspecDependency](commands/Add-NuspecDependency.md)
- [Add-NuspecFile](commands/Add-NuspecFile.md)
- [ConvertTo-NuspecManifest](commands/ConvertTo-NuspecManifest.md)
- [Get-NuGetPath](commands/Get-NuGetPath.md)
- [Get-NuspecProperty](commands/Get-NuspecProperty.md)
- [Get-NuspecSchema](commands/Get-NuspecSchema.md)
- [Install-NuGet](commands/Install-NuGet.md)
- [Invoke-NuGetCommand](commands/Invoke-NuGetCommand.md)
- [New-NuGetPackage](commands/New-NuGetPackage.md)
- [Resolve-NuspecProperty](commands/Resolve-NuspecProperty.md)
- [Set-NuspecLicense](commands/Set-NuspecLicense.md)
- [Set-NuspecProperty](commands/Set-NuspecProperty.md)
- [Test-NuspecManifest](commands/Test-NuspecManifest.md)
- [Update-NuGet](commands/Update-NuGet.md)

## Release Notes
0.0.9:
- Added support for Chocolatey-specific properties in ConvertTo-NuspecManifest, Resolve-NuspecProperty and Set-NuspecProperty
- Set-NuspecLicese: Force switch now removes licenseUrl if it had specified.

0.0.8:
- Install-NuGet: Fixed if bin folder is not present (as it is removed if empty when packaged);
- Updated tests.

0.0.7:
- Install-NuGet: New function that will install NuGet if not present when importing the module (can be used to update with Force switch).
- Update-NuGet: New function that will update NuGet to the latest version.

0.0.6:
- ConvertTo-NuspecManifest: Added support for PowerShell Script Info objects.

0.0.5:
- Bug fixes.

0.0.4:
- ConvertTo-NuspecManifest: Added support for Module objects.

0.0.3:
- Added files support (Add-NuspecContentFile and Add-NuspecFile);
- Set-NuspecLicense: New function that supports either SPDX license or file;
- Added a dependency on module Bca.Spdx.

0.0.2:
- Added new function for Nuspec properties (Get-NuspecProperty, Set-NuspecProperty, Resolve-NuspecProperty);
- ConvertTo-NuspecManifest: Moved a great deal of logic in Resolve-NuspecProperty.

0.0.1:
- First version.
---
[Bca.Nuget](https://github.com/baptistecabrera/bca-nuget)
