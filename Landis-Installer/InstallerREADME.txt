The installer for LANDIS-II is Windows Installer XML Toolset (WiX). Install the build tools from 
http://wixtoolset.org/releases/ and also install the Visual Studio extension for whatever version
is in use. These are needed in order to build the installer from within the Core-Model solution.
Right clicking the Landis_Installer project and selecting "reload" may be necessary after installing 
the build tools and the extension.

In order to build and install LANDIS-II, first build the Core Model project from within the solution
making sure that solution configuration is set to "Release". Once this is done, the built DLLs will
appear in the directory Core-Model-v7\build\Release. Return to the main directory and run the
Windows command script core_model_build. This essentially gathers all files pertinent to the install
and places them in the Core-Model-v7\build\Release\publish directory. This is the base directory
the installer looks at to package all necessary files for LANDIS-II and install them.

All files within the Core-Model-v7\build\Release\publish will be packaged by the installer and
installed onto C:\Program Files\LANDIS-II-v7\v7. This is LANDIS' main directory and where the
program runs from.

GDAL is currently configured to be installed by building the Library-Spatial solution, specifically
the RasterIO.Gdal project. Once the release version is built it places all necessary x64 GDAL files at
Library-Spatial\src\RasterIO.Gdal\bin\Release\netstandard2.0\gdal\x64. These files should be copied
and pasted into the Core-Model-v7\build\Release\publish directory in order for the install to
function correctly.

Updating the installer to change which files are installed is simple thanks to the WiX toolset
and Visual Studio extension. Simply place any new files within the Core-Model-v7\build\Release\publish
directory, then right click the Landis_Installer project from within the Core-Model solution and select
"build". This will automatically update the installer's code to package anything within the publish
directory as part of the install. The updated installer will be placed at
Core-Model-v7\deploy\installer\en-us.

This is a basic tutorial on how to code WiX installers beyond the simple steps given here:
http://wixtoolset.org/documentation/manual/v3/howtos/files_and_registry/add_a_file.html