# Bca.NuGet
![PowerShell Gallery](https://img.shields.io/powershellgallery/p/Bca.Nuget)
![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/Bca.Nuget?color=informational&logo=powershell&logoColor=white) ![Nuget](https://img.shields.io/nuget/v/Bca.Nuget?color=informational&logo=nuget&logoColor=white) ![Chocolatey Version](https://img.shields.io/chocolatey/v/bca-nuget?color=informational&logo=chocolatey&logoColor=white) 

## Description

_Bca.NuGet_ is a PowerShell module used to manage NuGet packages, but more importantly helps converting known-format manifests to `nuspec` (e.g. PowerShell Module Manifest, PowerShell Script Info), thus allowing you to maintain only one.

## Disclaimer

- _Bca.NuGet_ will install the latest version of _NuGet_ once at module import, but you can use the command `Update-NuGet` to update it. A future version will allow to specify another version or dynamically find it.
- _Bca.NuGet_ has been created to answer my needs to streamline my package automation, but I provide it to people who may need such a tool.
- It may contain bugs or lack some features, in this case, feel free to open an issue, and I'll manage it as best as I can.
- This _GitHub_ repository is not the primary one, see transparency for more information.
- Functions that use `nuget` command (such as `New-NuGetPackage`) are natively Windows-compatible only (for now), but there is a workaround:
  - Install [Mono 4.4.2 or later](https://www.mono-project.com/docs/getting-started/install/), or skip to the last step if [`dotnet` CLI](https://docs.microsoft.com/en-us/dotnet/core/tools/) is sufficient for your needs;
  - Call the function `Get-NuGetPath`, and create an alias to this command: `alias nuget="mono /path/to/nuget.exe"`
  - Call the function `Invoke-NuGetCommand` by using the `NuGetCommand` parameter with either the alias for `nuget.exe` or `dotnet`, for instance:
    - `Invoke-NuGetCommand -Command "restore" -NuGetCommand "nuget"`
    - `Invoke-NuGetCommand -Command "restore" -NuGetCommand "dotnet"`
    - `Invoke-NuGetCommand -Command "add" -Target "source https://api.nuget.org/v3/index.json" -Parameters @{ "name" = "NuGet.org" } -NuGetCommand "dotnet nuget"`

## Dependencies

- [`Bca.Spdx`](https://github.com/baptistecabrera/bca-spdx) version `0.0.8` or greater
- Although it is not a dependcy, _Bca.NuGet_ uses `Test-Xml` from module [`Pscx`](https://github.com/Pscx/Pscx), in the function `Test-NuspecManifest`.

## Examples

### Convert a PS Module Manifest

```ps
Import-PowerShellDataFile -Path .\MyModule.psd1 | ConvertTo-NuspecManifest | Save-NuspectManifest -Path "C:\MyModule.nuspec"
```

### Convert a PS Module Object

```ps
Get-Module -Name MyModule | ConvertTo-NuspecManifest | Save-NuspectManifest -Path "C:\MyModule.nuspec"
```

### Convert a PS Script Info

```ps
Test-ScriptFileInfo C:\MyScript.ps1 | ConvertTo-NuspecManifest | Save-NuspectManifest -Path "C:\MyScript.nuspec"
```

## Documentation
Find extended documentation [at this page](doc/ReadMe.md).

## How to install

### The easiest way

In a PowerShell console, run the following:
```ps
Find-Module -Name Bca.Nuget | Install-Module
```

### Package

_Bca.NuGet_ is available as a package from _[PowerShell Gallery](https://www.powershellgallery.com/)_, _[NuGet](https://www.nuget.org/)_ and _[Chocolatey](https://chocolatey.org/)_*, please refer to each specific plateform on how to install the package.

\* Availability on Chocolatey is subject to approval.

### Manually

If you decide to install _Bca.NuGet_ manually, copy the content of `src` into one or all of the path(s) contained in the variable `PSModulePath` depending on the scope you need.

I'll advise you use a path with the version, that can be found in the module manifest `psd1` file (e.g. `C:\Program Files\WindowsPowerShell\Modules\Bca.NuGet\1.0.0`). In that case copy the content of `src/Bca.NuGet` in this path.

## Transparency

_Please not that to date I am the only developper for this module._

- All code is primarily stored on a private Git repository on Azure DevOps;
- Issues opened in GitHub create a bug in Azure DevOps; [![Sync issue to Azure DevOps](https://github.com/baptistecabrera/bca-nuget/workflows/Sync%20issue%20to%20Azure%20DevOps/badge.svg)](https://github.com/baptistecabrera/bca-nuget/actions?query=workflow%3A"Sync+issue+to+Azure+DevOps")
- All pushes made in GitHub are synced to Azure DevOps (that includes all branches except `master`); [![Sync branches to Azure DevOps](https://github.com/baptistecabrera/bca-nuget/workflows/Sync%20branches%20to%20Azure%20DevOps/badge.svg)](https://github.com/baptistecabrera/bca-nuget/actions?query=workflow%3A"Sync+branches+to+Azure+DevOps")
- When a GitHub Pull Request is submitted, it is analyzed and merged in `develop` on GitHub, then synced to Azure DevOps that will trigger the CI;
- A Pull Request is then submitted in Azure DevOps to merge `develop` to `master`, it runs the CI again;
- Once merged to `master`, the CI is one last time, but this time it will create a Chocolatey and a NuGet packages that are pushed on private Azure DevOps Artifacts feeds;
- If the CI succeeds and the packages are well pushed, the CD is triggered.

### CI
[![Build Status](https://dev.azure.com/baptistecabrera/Bca/_apis/build/status/Build/Bca.Nuget?repoName=bca-nuget&branchName=master)](https://dev.azure.com/baptistecabrera/Bca/_build/latest?definitionId=15&repoName=bca-nuget&branchName=master)

The CI is an Azure DevOps build pipeline that will:
- Test the module with _[Pester](https://pester.dev/)_ tests;
- Run the _[PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer)_;
- Mirror the repository to GitHub

### CD
[![Build Status](https://dev.azure.com/baptistecabrera/Bca/_apis/build/status/Release/Bca.Nuget?repoName=bca-nuget&branchName=master)](https://dev.azure.com/baptistecabrera/Bca/_build/latest?definitionId=16&repoName=bca-nuget&branchName=master)

The CD is an Azure DevOps release pipeline is trigerred that will:
- In a **Prerelease** step, install both Chocolatey and Nuget packages from the private feed in a container, and run tests again. If tests are successful, the packages are promoted to `@Prerelease` view inside the private feed;
- In a **Release** step, publish the packages to _[NuGet](https://www.nuget.org/)_ and _[Chocolatey](https://chocolatey.org/)_, and publish the module to _[PowerShell Gallery](https://www.powershellgallery.com/)_, then promote the packages to to `@Release` view inside the private feed.
