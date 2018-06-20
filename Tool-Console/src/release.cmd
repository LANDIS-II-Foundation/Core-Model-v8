@ echo off

rem Run dotnet publish -c Release 
cd %cd%
echo %cd%
dotnet publish -c Release
for %%a in ("%~dp0..\..\") do set "SCRIPT_DIR=%%~fa"
echo %SCRIPT_DIR%

rem Delete linux-x64 and unix folder
set RUNTIMES=%SCRIPT_DIR%build\Release\publish\runtimes
echo %RUNTIMES%
@RD /s /q %RUNTIMES%\linux-x64
@RD /s /q %RUNTIMES%\unix
echo.
echo ******* Done *******