function Install-NuGet
{
    <#
        .SYNOPSIS
            Installs NuGet.exe.
        .DESCRIPTION
            Installs NuGet.exe.
        .PARAMETER Force
            A switch specifying whether or not to force the install if already installed.
        .EXAMPLE
            Install-NuGet

            Description
            -----------
            This example will install NuGet.exe.
        .NOTES
    #>
    [CmdLetBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch] $Force
    )
    
    try 
    {
        $NuGetPath = Get-NuGetPath
        if (!(Test-Path $NuGetPath) -or $Force)
        {
            $ParentDirectory = Split-Path -Path $NuGetPath -Parent
            if (!(Test-Path $ParentDirectory)) { New-Item -Path $ParentDirectory -ItemType Directory -Force | Out-Null }
            (New-Object System.Net.WebClient).DownloadFile("https://dist.nuget.org/win-x86-commandline/latest/nuget.exe", $NuGetPath)
            $env:Path += ";{0}" -f $ParentDirectory
        }
    }
    catch
    {
        Write-Error $_
    }
}