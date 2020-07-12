function Update-NuGet
{
    <#
        .SYNOPSIS
            Updates NuGet.exe.
        .DESCRIPTION
            Updates NuGet.exe.
        .PARAMETER Force
            A switch specifying whether or not to force the install if already installed.
        .EXAMPLE
            Update-NuGet

            Description
            -----------
            This example will install the last version of NuGet.exe.
        .NOTES
    #>
    [CmdLetBinding()]
    param()
    
    try 
    {
        Install-NuGet -Force
    }
    catch
    {
        Write-Error $_
    }
}