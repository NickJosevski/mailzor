#This build assumes the following directory structure
#
#  \Build          - This is where the project build code lives
#  \BuildArtifacts - This folder is created if it is missing and contains output of the build
#  \Code           - This folder contains the source code or solutions you want to build
#
Properties {
	$build_dir = Split-Path $psake.build_script_file	
    $code_dir = Resolve-Path "$build_dir\.."
	$build_artifacts_dir = "$code_dir\Build\Output\"
	$build_proj = "$code_dir\mailzor-only.sln"
    $build_number
    $vcs_number
    $keyFile = "$code_dir\mailzor.snk"
    $assemblies
    $vs_build_dir
    $lib_name
    $vs_project_dir
}
include .\psake_ext.ps1

FormatTaskName (("-"*25) + "[{0}]" + ("-"*25))

Task Default -Depends BuildEverything

Task BuildEverything -Depends Clean, Build

Task Build -Depends Clean, Init {	

	Write-Host "Building mailzor.sln" -ForegroundColor Green
	
	Exec { msbuild $build_proj /t:Build /p:Configuration=Release /v:normal /p:OutDir=$build_artifacts_dir /p:SignAssembly=true /p:AssemblyOriginatorKeyFile=$keyFile} 
	if ($lastexitcode -ne 0)
	{
		exit 1
	}
	
	Exec { cd NuGet } 
	Remove-Item *.nupkg
	Exec { .\NuGet.exe Pack mailzor.nuspec -BasePath . } 
	if ($lastexitcode -ne 0)
	{
		exit 1
	}
}

Task Clean {
    Write-Host "Cleaning" -ForegroundColor Green
    	
	if (!(Test-Path -path $build_artifacts_dir))
	{
		New-Item $build_artifacts_dir -type directory
	}
	
    Write-Host "Cleaning mailzor.sln" -ForegroundColor Green
	Exec { msbuild $build_proj /t:Clean /p:Configuration=Release /v:normal } 
	if ($lastexitcode -ne 0)
	{
		exit 1
	}
}

task Init {  

    Write-Host "init does nothing"

}
