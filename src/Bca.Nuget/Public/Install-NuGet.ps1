function Install-NuGet
{
    <#
        .SYNOPSIS
            Installs NuGet.exe.
        .DESCRIPTION
            Installs NuGet.exe.
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
            (New-Object System.Net.WebClient).DownloadFile("https://dist.nuget.org/win-x86-commandline/latest/nuget.exe", $NuGetPath)
        }
    }
    catch
    {
        Write-Error $_
    }
}