# Bca.Nuget `0.2.0`
Tags: `Linux` `MacOS` `NuGet` `Package` `PackageManager` `Packaging` `Windows`

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
- [Resolve-NuspecRepository](commands/Resolve-NuspecRepository.md)
- [Save-NuspecManifest](commands/Save-NuspecManifest.md)
- [Set-NuspecLicense](commands/Set-NuspecLicense.md)
- [Set-NuspecProperty](commands/Set-NuspecProperty.md)
- [Set-NuspecRepository](commands/Set-NuspecRepository.md)
- [Test-NuspecManifest](commands/Test-NuspecManifest.md)
- [Update-NuGet](commands/Update-NuGet.md)

## Release Notes
0.2.0:
- Resolve-Nuspecproperty and Set-NuspecProperty now supporting repository, icon and requireLicenseAcceptance prpoperties;
- Resolve-NuspecRepository: new function that resolves a repository object from an URL;
- Set-NuspecRepository: new function that sets the repository property to a Nuspec manifest.

0.1.0:
- This version now supports certain Chocolatey-specific properties in ConvertTo-NuspecManifest, Resolve-NuspecProperty and Set-NuspecProperty;
- Save-NuspecManifest: New function to save a Nuspec manifest to a file;
- Set-NuspecLicese: Force switch now removes licenseUrl if it had specified;
- Get-NuspecProperty: Value now returns an array instead of a list of nodes if multiple (e.g. property name dependencies will return an array of id and version as the value instead of an array of dependency);
- Bug fixes.

---
[Bca.Nuget](https://github.com/baptistecabrera/bca-nuget)
