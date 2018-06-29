@ echo off

rem Run dotnet publish -c Release 
cd %cd%
set CONSOLE=%cd%\Tool-Console\src\Console.csproj
set EXTENSION=%cd%\Tool-Extension-Admin\src\Extension_Admin.csproj
set BUILD_DIR=%cd%\build
set DEPLOY_DIR=%BUILD_DIR%\Release\publish
set EXTENSION_BUILD_DIR=%cd%\Tool-Extension-Admin\src\bin\Release


rem Build Tool-Console
dotnet publish %CONSOLE% -c Release
echo Tool-Console publish done

rem Delete linux-x64 and unix folder
set RUNTIMES=%BUILD_DIR%\Release\publish\runtimes
echo %RUNTIMES%
@RD /s /q %RUNTIMES%\linux-x64
@RD /s /q %RUNTIMES%\unix

rem Build Tool-Extension-Admin
dotnet build %EXTENSION% -c Release

rem copy files in deploy
pushd %EXTENSION_BUILD_DIR%
for /r %%a in (*) do (
copy "%%a" %DEPLOY_DIR%"\%%~nxa"
)
popd

echo.
echo ********** Done **********
