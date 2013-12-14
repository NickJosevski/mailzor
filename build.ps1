Param (
    [parameter(Position=0)]
    [String[]]
    $Task = "",
	[parameter(Position=1)]
    [String[]]
    $config = "Debug",
	[parameter(Position=2)]
    [String[]]
    $build_number = "1.0.0.1"
) 

Write-host $Task
$scriptPath = Split-Path $MyInvocation.InvocationName
$psakeDir = join-path $scriptPath "Build"
Import-Module (join-path $psakeDir psake.psm1) -force
$psakeScript = join-path $psakeDir "mailzor-build.ps1"
Invoke-psake $psakeScript -framework '4.0' $Task -properties @{"configuration"="$config"; "build_number"="$build_number"}