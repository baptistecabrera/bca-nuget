function Get-NuGetPath
{
    <#
        .SYNOPSIS
            Gets the executable path of NuGet.exe.
        .DESCRIPTION
            Gets the executable path of NuGet.exe.
        .INPUTS
            None
        .OUTPUTS
            System.String
            Returns a string containing the path to NuGet.exe.
        .EXAMPLE
            Get-NuGetPath

            Description
            -----------
            This example will return the path of NuGet.exe.
        .NOTES
    #>
    [CmdLetBinding()]
    param()
    
    try 
    {
        (Join-Path (Join-Path (Split-Path $PSScriptRoot -Parent) "bin") "nuget.exe")
    }
    catch
    {
        Write-Error $_
    }
}