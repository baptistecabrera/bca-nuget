# Gets public and private function definition files.
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Recurse -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Recurse -ErrorAction SilentlyContinue )

# Dot source the files
foreach ($File in @($Public + $Private))
{
    try
    {
        . $File.FullName
    }
    catch
    {
        Write-Error -Message "Failed to import function $($File.BaseName): $_"
    }
}

Export-ModuleMember -Function $Public.BaseName -Variable * -Alias *