cd Build
powershell -NoProfile -ExecutionPolicy unrestricted -File .\psake.ps1 "mailzor-build.ps1" BuildEverything -framework 4.0x64
cd ..