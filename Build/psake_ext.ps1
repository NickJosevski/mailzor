function Merge-Assemblies($key, $directory, $name, $assemblies, $extension, $internalizeExcludesFile)
{    
    # Create a new temp directory as we cannot overwrite the main assembly being merged.
    new-item -path $directory -name "temp_merge" -type directory -ErrorAction SilentlyContinue
    
    if (Test-Path $internalizeExcludesFile) {
        $internalizeExcludesFile = ":""$internalizeExcludesFile""";
    } else {
        $internalizeExcludesFile = "";
    }
    
    # Unfortuntately we need to tell ILMerge its merging CLR 4 assemblies.
    if($framework -eq "4.0")
    {
        Exec { ..\Tools\ilmerge.exe /internalize$internalizeExcludesFile /keyfile:$key /out:"$directory\temp_merge\$name.$extension" "$directory\$name.$extension" $assemblies /targetplatform:"v4" }
    }
    else
    {
        Exec { ..\Tools\ilmerge.exe /internalize$internalizeExcludesFile /keyfile:$key /out:"$directory\temp_merge\$name.$extension" "$directory\$name.$extension" $assemblies }
    }
    
    Get-ChildItem "$directory\temp_merge\**" -Include *.dll, *.pdb | Copy-Item -Destination $directory
    Remove-Item "$directory\temp_merge" -Recurse -ErrorAction SilentlyContinue
}

function Generate-Key-Pair
{
param(
    [string]$keyFile = $(throw "keyFile is a required parameter.")
)
    $dir = [System.IO.Path]::GetDirectoryName($keyFile)
	if ([System.IO.Directory]::Exists($dir) -eq $false)
	{
		Write-Host "Creating directory $dir"
		[System.IO.Directory]::CreateDirectory($dir)
	}
    $exe = "..\Tools\sn.exe";
    &$exe -k $keyFile
}



function Generate-Public-Key-Token
{
param(
    [string]$keyFile = $(throw "keyFile is a required parameter.")
)
    $exe = "..\Tools\sn.exe";
    
    &$exe -q -p $keyFile publicKey.snk
    [string]$token = &$exe -q -tp publicKey.snk 
    del publicKey.snk 
    
    #$token
    
    $startIndex = $token.IndexOf('Public key is ')+'Public key is '.Length
    $endIndex = $token.IndexOf('  Public key token is ')
    $pkLength = $endIndex - $startIndex
    
    $token = $token.Substring($startIndex, $pkLength).Replace(' ', '')
    
    $token
}

#Generate-Public-Key-Token "C:\work\daedalus-src\_Shared\Daedalus.snk"

function Generate-Assembly-Info
{
param(
	[string]$clsCompliant = "true",
	[string]$title, 
	[string]$description, 
	[string]$company, 
	[string]$product, 
	[string]$copyright, 
	[string]$version,
    [string]$revision,
	[string]$file = $(throw "file is a required parameter."),
    [string]$snkPublicKeyToken = $(throw "snkPublicKeyToken is a required parameter.")
)
  $asmInfo = "// --------------------------------------------------------------------------------------------------------------------
// <copyright file=""globalAssemblyInfo.cs"" company=""Picnic Software Pty Ltd"">
//   © 2012 Picnic Software Pty Ltd
// </copyright>
// <summary>
//   globalAssemblyInfo.cs
// </summary>
// --------------------------------------------------------------------------------------------------------------------

using System;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;

[assembly: CLSCompliantAttribute($clsCompliant)]
[assembly: ComVisibleAttribute(false)]
[assembly: AssemblyCompanyAttribute(""$company"")]
[assembly: AssemblyProductAttribute(""$product"")]
[assembly: AssemblyCopyrightAttribute(""$copyright"")]
[assembly: AssemblyVersionAttribute(""$version"")]
[assembly: AssemblyInformationalVersionAttribute(""$version"")]
[assembly: AssemblyFileVersionAttribute(""$version"")]
[assembly: AssemblyDelaySignAttribute(false)]
[assembly: InternalsVisibleTo(""Tests.Slow.Daedalus"")]
[assembly: InternalsVisibleTo(""Tests.Daedalus"")]"

	$dir = [System.IO.Path]::GetDirectoryName($file)
	if ([System.IO.Directory]::Exists($dir) -eq $false)
	{
		Write-Host "Creating directory $dir"
		[System.IO.Directory]::CreateDirectory($dir)
	}
	Write-Host "Generating assembly info file: $file"
	out-file -filePath $file -encoding UTF8 -inputObject $asmInfo
}

function Generate-Nuspec-File 
{
param( 
	[string]$version,
	[string]$file = $(throw "file is a required parameter.")
)
  $contents = "<?xml version=""1.0""?>
<package xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" xmlns:xsd=""http://www.w3.org/2001/XMLSchema"">
  <metadata xmlns=""http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd"">
    <id>AdCast</id>
    <version>$version</version>
    <authors>Picnic Software Pty Ltd</authors>
    <requireLicenseAcceptance>false</requireLicenseAcceptance>
    <description>AdCast Marketing Automation</description>
    <summary>Picnic Software</summary>
    <language>en-US</language>
    <tags>AdCast</tags>
    <projectUrl>https://svn.adcastgroup.com/svn/repos/AdCast/trunk</projectUrl>
    <iconUrl></iconUrl>
  </metadata>
</package>
"

	$dir = [System.IO.Path]::GetDirectoryName($file)
	if ([System.IO.Directory]::Exists($dir) -eq $false)
	{
		Write-Host "Creating directory $dir"
		[System.IO.Directory]::CreateDirectory($dir)
	}
	Write-Host "Generating nuspec file: $file"
	out-file -filePath $file -encoding UTF8 -inputObject $contents
}