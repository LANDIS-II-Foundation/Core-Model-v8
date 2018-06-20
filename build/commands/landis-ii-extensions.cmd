@echo off

for %%a in ("%~dp0..\") do set "SCRIPT_DIR=%%~fa"
set LandisExtensions=%SCRIPT_DIR%v7\Landis.Extensions.dll
echo %LandisExtensions%
dotnet "%LandisExtensions%" %*
