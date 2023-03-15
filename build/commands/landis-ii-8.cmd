@echo off

for %%a in ("%~dp0..\") do set "SCRIPT_DIR=%%~fa"
set LandisConsole=%SCRIPT_DIR%v8\Landis.Console.dll
dotnet "%LandisConsole%" %*






