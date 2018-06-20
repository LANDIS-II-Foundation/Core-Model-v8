@ echo off

rem Run dotnet publish -c Release 
cd %cd%
echo %cd%
rem dotnet build -c Release
for %%a in ("%~dp0..\..\") do set "SCRIPT_DIR=%%~fa"
echo %SCRIPT_DIR%

rem Delete linux-x64 and unix folder
set BIN=%SCRIPT_DIR%build\Release\publish
echo %BIN%
if exist %BIN% (
echo yes
) else (
echo Run "Console" first
)

echo.
echo ******* Done *******