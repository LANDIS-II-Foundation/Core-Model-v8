# Building and debugging LANDIS-II source code on Windows

By Kelsey Ruckert and Jared Oyler

Here we describe a procedure for setting up a development environment on Windows to build and debug LANDIS-II.

## Prerequisites

* [Visual Studio Community Edition](https://www.visualstudio.com/downloads): In these instructions, we use Visual Studio Community Edition 2017 (VS2017). VS2017 is one of the most popular and full-featured Integrated Development Environments for C# and .NET development.
* [Git for Windows](https://git-for-windows.github.io): LANDIS-II uses git for version control and source code management.
* [LANDIS-II Source Code](https://github.com/LANDIS-II-Foundation): LANDIS-II source code is available across numerous GitHub repositories available under the LANDIS-II Foundation GitHub organization. The main LANDIS-II model framework is stored in the [Core-Model repository](https://github.com/LANDIS-II-Foundation/Core-Model) and is required. The exact additional LANDIS Foundation-II libraries and extensions that are required vary by the model scenario being run. Instead of cloning the required repositories on a case-by-case basis, we recommend cloning all LANDIS-II Foundation GitHub repositories in bulk so that they are all available locally. This can be accomplished in Git BASH, part of Git For Windows. Open a Git BASH window (by default, Git BASH opens to your home user directory) and create a directory for the LANDIS-II source code:

        > mkdir landisII_source
        > cd landisII_source
Within the landisII_source directory, run the following command (courtesy of LANDIS-II Developers Bulletin Board [post](http://www.landis-ii.org/developers?place=msg%2Flandis-ii-developers%2FzlplWxZSZ4I%2FdGAgIv7QAAAJ)) to clone all the LANDIS-II Foundation repositories:
    
        > ORG=landis-ii-foundation; curl "https://api.github.com/orgs/$ORG/repos?page=$PAGE&per_page=100" | grep -e 'git_url*' | cut -d \" -f 4 | xargs -L1 git clone 

Be patient, as the repository downloads will take several minutes. Once downloaded, you can exit the Git BASH window. 

## Step 1: Setup Visual Studio Solution

The first step is to setup a VS2017 solution for the LANDIS-II source code. A solution is a container for projects and manages inter-project dependencies. A project typically contains code for one piece of functionality, either a shared library or an executable. VS2017 solutions are defined in .sln files and projects in .csproj files. The [Core-Model repository](https://github.com/LANDIS-II-Foundation/Core-Model) contains a [premake LUA script](https://premake.github.io) to create a  pre-configured .sln file along with corresponding .csproj files for setting up a LANDIS-II solution. Open a command prompt and navigate to the local copy of the Core-Model and run the following command to execute the premake script. To increase efficiency, create a user environment variable, LANDISII\_SOURCE, that points to the landisII_source directory. We will use this environmental variable throughout the rest of the instructions.

    > set LANDISII_SOURCE=C:\path\to\landisII_source
    > cd %LANDISII_SOURCE%\Core-Model\model
    > premake5 vs2017

A LANDIS-II.sln file will be generated in the %LANDISII_SOURCE%\Core-Model\model directory. To load the solution in VS2017, open VS2017 --> select "Open Project / Solution" --> navigate to the location of the LANDIS-II.sln file --> select the LANDIS-II.sln file and open. The LANDIS-II solution will load with 7 total Core-Model projects:

* Console
* Core
* Core_Implementation
* Ecoregions_Tests 
* Extension_Admin
* Extension Dataset
* Species_Tests

The Ecoregions\_Tests and Species\_Tests projects contain unit tests that use the [NUnit](http://nunit.org) unit-testing framework. However, these tests appear to be broken due to usage of an old version of NUnit. At this time, remove these broken projects from the solution by right clicking the `project --> Remove`.

## Step 2: Setup Core-Model Dependencies

Within each project, is a Reference section that lists the project's dependencies. Dependencies can include third party libraries and other LANDIS-II utilities and libraries. Many of the dependencies will show a yellow exclamation mark symbol. This symbol means that the required dependency cannot be found. As a result, the LANDIS-II solution will not build in its current state. Here we describe how to fix the broken dependencies. In the current documentation for LANDIS-II, the solution to inter-project dependencies is to download and reference prebuilt LANDIS-II library DLLs stored in the [Support-Library-Dlls repository](https://github.com/LANDIS-II-Foundation/Support-Library-Dlls). We avoid this approach, because we want to build and debug all LANDIS-II support libraries and extensions entirely from source. For several libraries, this is currently unavoidable. So that DLLs for these exceptions are available locally, run the following command to download the DLLs from the Support-Library-Dlls repository:
    
    > cd %LANDISII_SOURCE%\Core-Model\model
    > install-libs_CoreModel.cmd

Across the 5 projects in the Core-Model solution, the following dependencies are broken and need to be added:

* [log4net](http://logging.apache.org/log4net/index.html)
* [Troschuetz Random Number Library](https://www.codeproject.com/articles/15102/net-random-number-generators-and-distributions)
* LANDIS-II [Edu.Wisc.Forest.Flel.Util](https://github.com/LANDIS-II-Foundation/Support-Library-Dlls/blob/master/Edu.Wisc.Forest.Flel.Util.dll)
* LANDIS-II [Library-Spatial](https://github.com/LANDIS-II-Foundation/Library-Spatial) (contains 4 separate assemblies)

### [log4net](http://logging.apache.org/log4net/index.html)
Log4net is a third party library that can be added to the solution via [NuGet](https://www.nuget.org/). Right click `solution --> Manage NuGet Packages for Solution --> Browse` tab. Search for "log4net" and install it to the Console and Core\_Implementation projects. Another way to add this library is via the Pacakge Manager Console. In the tool bar, click `Tools --> Nuget Package Manager --> Package Manager Console`. In the console, set the "Default project" to Console and type the command listed below (double check that you have the most up-to-date version before installing; see [log4net](https://www.nuget.org/packages/log4net/)). After completed, change the "Default project" to Core\_Implementation to install it there as well.

    PM> Install-Package log4net -Version 2.0.8

Log4net also needs to have an entry in the application configuration file for LANDIS-II. The configuration file is part of the Core-Model  repository, but needs to be added to the Console project: right click `Console --> Add --> Existing Item... -->` navigate to and select %LANDISII\_SOURCE%\Core-Model\model\console\Landis.Console-X.Y.exe.config. If the config file does not immediately appear in the browser selection window, make sure that "All Files (\*.\*)" is selected in the lower right portion of the window. After adding the config file, replace the "X.Y" section of the filename with "6.2" or the current version number. Open the config file and note the log4net configuration elements. Remove the `<dependentAssembly>` element for gdal_csharp and save the file. This section is no longer needed because we will be building libraries that reference GDAL from source. Lastly, in the properties window for the config file, set "Copy to Output Directory" to "Copy always". 

### [Troschuetz Random Number Library](https://www.codeproject.com/articles/15102/net-random-number-generators-and-distributions) and LANDIS-II [Edu.Wisc.Forest.Flel.Util](https://github.com/LANDIS-II-Foundation/Support-Library-Dlls/blob/master/Edu.Wisc.Forest.Flel.Util.dll)
Troschuetz Random Number Library is also available via NuGet, but LANDIS-II appears to use an old version of this library, so we will point to the DLL that was downloaded from the Support-Library-Dlls repository. Similarly, there does not appear to be any source for Edu.Wisc.Forest.Flel.Util, so we will also point to the local DLL. Below is a list of the DLL reference dependencies that must be removed and added by project. To remove a broken reference, right click `broken reference --> Remove`. To add a direct path DLL reference, right click `References --> Add Reference --> Browse tab --> click Browse button -->` and select the DLL. 

* Console
	- Remove broken DLL references
	    + Edu.Wisc.Forest.Flel.Util.dll
    - Add direct path DLL reference to
        + Edu.Wisc.Forest.Flel.Util.dll (%LANDISII\_SOURCE%\Core-Model\model\libs\Edu.Wisc.Forest.Flel.Util.dll)   
* Core
	- Remove broken DLL references
	    + Edu.Wisc.Forest.Flel.Util.dll
	    + Troschuetz.Random.dll
    - Add direct path DLL reference to
        + Edu.Wisc.Forest.Flel.Util.dll (%LANDISII\_SOURCE%\Core-Model\model\libs\Edu.Wisc.Forest.Flel.Util.dll)
        + Troschuetz.Random.dll (%LANDISII\_SOURCE%\Core-Model\model\libs\Troschuetz.Random.dll)
* Core_Implementation
	- Remove broken DLL references
	    + Edu.Wisc.Forest.Flel.Util.dll
	    + Troschuetz.Random.dll
    - Add direct path DLL reference to
        + Edu.Wisc.Forest.Flel.Util.dll (%LANDISII\_SOURCE%\Core-Model\model\libs\Edu.Wisc.Forest.Flel.Util.dll)
        + Troschuetz.Random.dll (%LANDISII\_SOURCE%\Core-Model\model\libs\Troschuetz.Random.dll)
* Extension_Admin
	- Remove broken DLL references
	    + Edu.Wisc.Forest.Flel.Util.dll
    - Add direct path DLL reference to
        + Edu.Wisc.Forest.Flel.Util.dll (%LANDISII\_SOURCE%\Core-Model\model\libs\Edu.Wisc.Forest.Flel.Util.dll) 
* Extension Dataset
	- Remove broken DLL references
	    + Edu.Wisc.Forest.Flel.Util.dll
    - Add direct path DLL reference to
        + Edu.Wisc.Forest.Flel.Util.dll (%LANDISII\_SOURCE%\Core-Model\model\libs\Edu.Wisc.Forest.Flel.Util.dll)
        

### LANDIS-II [Library-Spatial](https://github.com/LANDIS-II-Foundation/Library-Spatial) (contains 4 separate assemblies)
The LANDIS-II Library-Spatial contains 4 different assemblies each with its own corresponding VS2017 .csproj project file. Add each one of these projects to the LANDIS-II solution (Right click `Solution --> Add --> Existing Project`). The local paths to the Library-Spatial .csproj files are as follows:

    %LANDISII_SOURCE%\Library-Spatial\src\api\Landis_SpatialModeling.csproj
    %LANDISII_SOURCE%\Library-Spatial\src\Landscapes\Landis_Landscapes.csproj
    %LANDISII_SOURCE%\Library-Spatial\src\RasterIO\Landis_RasterIO.csproj
    %LANDISII_SOURCE%\Library-Spatial\src\RasterIO.Gdal\Landis_RasterIO_Gdal.csproj

These Library-Spatial projects are configured to target the .NET 4.0 framework, but the rest of the Core projects are targeted at .NET 3.5. To make the Library-Spatial projects match the Core projects, change each one to target .NET 3.5: right click `project --> Properties --> Target framework --> .NET Framework 3.5`.

The Landis\_RasterIO\_Gdal project depends on GDAL, a native C library. The library is used in C# with SWIG generated C# bindings. The GDAL library and the corresponding bindings are included within the Landis\_RasterIO\_Gdal project. To ensure that the native GDAL DLLs are available at runtime, add a post build event to the Landis\_RasterIO\_Gdal project to copy the DLLs to the target directory of the Core solution build: right click `project --> Properties --> Build Events tab -->` Edit Post-build event command line. Enter the following command:

    xcopy "$(ProjectDir)..\..\third-party\GDAL\native\*.*" "$(SolutionDir)build\$(ConfigurationName)" /Y

The next step is to add appropriate references in the relevant Core projects to the Library-Spatial projects. For all projects, remove any spatial-related references that are broken. For the Core, Console, Core\_Implementation, and Extension\_Admin projects, add a reference to the Landis\_SpatialModeling project. Additionally, add references to the Landis\_Landscapes, Landis\_RasterIO, and Landis\_RasterIO\_Gdal projects for the Console project. To add a project reference, right click `References --> Add Reference --> Projects tab -->` and check projects that should be added as a reference. Below is the list of project reference dependencies to add.

* Console
	- Add project references to
		+ Landis_SpatialModeling project
		+ Landis_Landscapes project
		+ Landis_RasterIO project
		+ Landis\_RasterIO\_Gdal project  
* Core
	- Add project references to
		+ Landis_SpatialModeling project
* Core_Implementation
	- Add project references to
		+ Landis_SpatialModeling project
* Extension_Admin
	- Add project references to
		+ Landis_SpatialModeling project

The Core-Model solution should now be setup for a successful build. Rebuild the solution and all associated projects: Right click `Solution --> Rebuild Solution`. Ensure that the build is successful. For later model runs, also ensure that the Console project is set as the StartUp Project. If it is, the Console project will be bolded. If not, right click `Console project --> Set As StartUp Project`. 

## Step 3: Add and Setup Extension and Library Projects

In this step, we add and setup VS2017 projects for the LANDIS-II extensions and libraries that are required for an example model run scenario. We will be using the [Age Only Succession scenario](https://github.com/LANDIS-II-Foundation/Extension-Age-Only-Succession/tree/master/deploy/examples) as our example. The following additional LANDIS-II extensions and libraries are required for this example scenario:

* Library-Age-Cohort
* Extension-Age-Only-Succession
* Extension-Base-BDA
* Extension-Base-Fire
* Extension-Base-Harvest
* Extension-Base-Wind
* Library-Harvest-Mgmt
* Library-Succession
* Extension-Output-Max-Species-Age
* Library-Metadata
* Extension-Output-Cohort-Statistics
* Library-Site-Harvest

Navigate to the local copies of the listed extensions and libraries and add them as individual projects within the VS2017 LANDIS-II solution (Right click `Solution --> Add --> Existing Project -->` navigate to and select the provided .csproj file of the extension/library). The exact paths of the .csproj files for the listed extensions and libraries are as follows:

    %LANDISII_SOURCE%\Library-Age-Cohort\src\age cohort.csproj
    %LANDISII_SOURCE%\Extension-Age-Only-Succession\src\age-only-successsion.csproj
    %LANDISII_SOURCE%\Extension-Base-BDA\src\base-BDA.csproj
    %LANDISII_SOURCE%\Extension-Base-Fire\src\base-fire.csproj
    %LANDISII_SOURCE%\Extension-Base-Harvest\src\base-harvest.csproj
    %LANDISII_SOURCE%\Extension-Base-Wind\src\base-wind.csproj
    %LANDISII_SOURCE%\Library-Harvest-Mgmt\src\harvest-mgmt-lib.csproj
    %LANDISII_SOURCE%\Library-Succession\src\library-succession.csproj
    %LANDISII_SOURCE%\Extension-Output-Max-Species-Age\src\max-species-age.csproj
    %LANDISII_SOURCE%\Library-Metadata\src\Metadata.csproj
    %LANDISII_SOURCE%\Extension-Output-Cohort-Statistics\src\output-cohort-stats.csproj
    %LANDISII_SOURCE%\Library-Site-Harvest\src\site-harvest-lib.csproj

Similar to the Core projects, many of the dependencies listed in References section of the newly added projects will be broken and will show a yellow exclamation mark symbol. To fix these dependencies, first remove errant NuGet packages.config files from the following projects:

* harvest-mgmt-lib
* age-only-succession

Each of the newly add projects will also have a pre-build command to download pre-built LANDIS-II DLLs. Because we are building from source, remove this pre-build command from each of the projects: right click `project --> Properties --> Build Events ->` remove the command in the "Pre-build event command line" text box.

Below is a list of the reference dependencies that must be removed and added by project. To remove a broken reference, right click `broken reference --> Remove`. To add a project reference, right click `References --> Add Reference --> Projects tab -->` check projects that should be added as a reference. To add a direct path DLL reference, right click `References --> Add Reference --> Browse tab -->` browse and select DLL. To add a NuGet package reference, right click `solution --> Manage NuGet Packages for Solution --> select package -->` check project to which package should be added and click Install button. 

* age cohort
	* Remove broken references
	    * Landis.Core
	    * Landis.Library.Cohorts
	    * Landis.SpatialModeling
    * Add project references to
        * Core project
        * Landis_SpatialModeling project
    * Add direct path DLL reference to
        * Landis.Library.Cohorts (%LANDISII\_SOURCE%\Core-Model\model\libs\Landis.Library.Cohorts.dll)    
* age-only-succession
    * Remove broken references
        * Edu.Wisc.Forest.Flel.Util
        * Landis.Core
        * Landis.Library.AgeOnlyCohorts
        * Landis.Library.Cohorts
        * Landis.Library.Succession-v5
        * Landis.SpatialModeling
    * Add project references to
        * Core project
        * age cohort project
        * library-succession project
        * Landis_SpatialModeling project
    * Add direct path DLL reference to
        * Landis.Library.Cohorts (%LANDISII\_SOURCE%\Core-Model\model\libs\Landis.Library.Cohorts.dll) 
        * Edu.Wisc.Forest.Flel.Util.dll (%LANDISII\_SOURCE%\Core-Model\model\libs\Edu.Wisc.Forest.Flel.Util.dll)
* base-BDA
	- Remove broken references
		+ Edu.Wisc.Forest.Flel.Util
        + Landis.Core
        + Landis.Library.AgeOnlyCohorts
        + Landis.Library.Cohorts
        + Landis.Library.Metdata
        + Landis.SpatialModeling
	- Add project references to
		+ Core project
		+ age cohort project
		+ Metadata project
		+ Landis_SpatialModeling project
    - Add direct path DLL reference to
		+ Landis.Library.Cohorts (%LANDISII\_SOURCE%\Core-Model\model\libs\Landis.Library.Cohorts.dll)
		+ Edu.Wisc.Forest.Flel.Util.dll (%LANDISII\_SOURCE%\Core-Model\model\libs\Edu.Wisc.Forest.Flel.Util.dll) 
		+ Troschuetz.Random.dll (%LANDISII\_SOURCE%\Core-Model\model\libs\Troschuetz.Random.dll)
* base-fire
	- Remove broken references
		+ Edu.Wisc.Forest.Flel.Util
        + Landis.Core
        + Landis.Library.AgeOnlyCohorts
        + Landis.Library.Cohorts
        + Landis.Library.Metdata
        + Landis.SpatialModeling
	- Add project references to
		+ Core project
		+ age cohort project
		+ Metadata project
		+ Landis_SpatialModeling project
    - Add direct path DLL reference to
		+ Landis.Library.Cohorts (%LANDISII\_SOURCE%\Core-Model\model\libs\Landis.Library.Cohorts.dll)
		+ Edu.Wisc.Forest.Flel.Util.dll (%LANDISII\_SOURCE%\Core-Model\model\libs\Edu.Wisc.Forest.Flel.Util.dll) 
		+ Troschuetz.Random.dll (%LANDISII\_SOURCE%\Core-Model\model\libs\Troschuetz.Random.dll)
* base-harvest
	- Remove broken references
		+ Edu.Wisc.Forest.Flel.Util
        + Landis.Core
        + Landis.Library.AgeOnlyCohorts
        + Landis.Library.Cohorts
        + Landis.Library.HarvestManagement-v2
        + Landis.Library.Metdata
        + Landis.Library.SiteHarvest-v1
        + Landis.Library.Succession-v5
        + Landis.SpatialModeling
        + log4net
	- Add project references to
		+ Core project
		+ age cohort project
		+ harvest-mgmt-lib project
		+ Metadata project
		+ site-harvest-lib project
		+ library-succession project
		+ Landis_SpatialModeling project
    - Add direct path DLL reference to
		+ Landis.Library.Cohorts (%LANDISII\_SOURCE%\Core-Model\model\libs\Landis.Library.Cohorts.dll)
		+ Edu.Wisc.Forest.Flel.Util.dll (%LANDISII\_SOURCE%\Core-Model\model\libs\Edu.Wisc.Forest.Flel.Util.dll)
	- Add NuGet package reference to
		+ log4net 
* base-wind
	- Remove broken references
		+ Edu.Wisc.Forest.Flel.Util
        + Landis.Core
        + Landis.Library.AgeOnlyCohorts
        + Landis.Library.Cohorts
        + Landis.Library.Metdata
        + Landis.SpatialModeling
	- Add project references to
		+ Core project
		+ age cohort project
		+ Metadata project
		+ Landis_SpatialModeling project
    - Add direct path DLL reference to
		+ Landis.Library.Cohorts (%LANDISII\_SOURCE%\Core-Model\model\libs\Landis.Library.Cohorts.dll)
		+ Edu.Wisc.Forest.Flel.Util.dll (%LANDISII\_SOURCE%\Core-Model\model\libs\Edu.Wisc.Forest.Flel.Util.dll)
		+ Troschuetz.Random.dll (%LANDISII\_SOURCE%\Core-Model\model\libs\Troschuetz.Random.dll)
* harvest-mgmt-lib
	- Remove broken references
		+ Edu.Wisc.Forest.Flel.Util
        + Landis.Core
        + Landis.Library.AgeOnlyCohorts
        + Landis.Library.Cohorts
        + Landis.Library.SiteHarvest-v1
        + Landis.Library.Succession-v5
        + Landis.SpatialModeling
        + log4net
	- Add project references to
		+ Core project
		+ age cohort project
		+ site-harvest-lib project
		+ library-succession project
		+ Landis_SpatialModeling project
    - Add direct path DLL reference to
		+ Landis.Library.Cohorts (%LANDISII\_SOURCE%\Core-Model\model\libs\Landis.Library.Cohorts.dll)
		+ Edu.Wisc.Forest.Flel.Util.dll (%LANDISII\_SOURCE%\Core-Model\model\libs\Edu.Wisc.Forest.Flel.Util.dll)
	- Add NuGet package reference to
		+ log4net 
* library-succession
	- Remove broken references
		+ Edu.Wisc.Forest.Flel.Util
        + Landis.Core
        + Landis.Library.AgeOnlyCohorts
        + Landis.Library.Cohorts
        + Landis.SpatialModeling
        + log4net
	- Add project references to
		+ Core project
		+ age cohort project
		+ Landis_SpatialModeling project
    - Add direct path DLL reference to
		+ Landis.Library.Cohorts (%LANDISII\_SOURCE%\Core-Model\model\libs\Landis.Library.Cohorts.dll)
		+ Edu.Wisc.Forest.Flel.Util.dll (%LANDISII\_SOURCE%\Core-Model\model\libs\Edu.Wisc.Forest.Flel.Util.dll)
	- Add NuGet package reference to
		+ log4net
* max-species-age
	- Remove broken references
		+ Edu.Wisc.Forest.Flel.Util
        + Landis.Core
        + Landis.Library.AgeOnlyCohorts
        + Landis.Library.Cohorts
        + Landis.Library.Metadata
        + Landis.SpatialModeling
	- Add project references to
		+ Core project
		+ age cohort project
		+ Metadata project
		+ Landis_SpatialModeling project
    - Add direct path DLL reference to
		+ Landis.Library.Cohorts (%LANDISII\_SOURCE%\Core-Model\model\libs\Landis.Library.Cohorts.dll)
		+ Edu.Wisc.Forest.Flel.Util.dll (%LANDISII\_SOURCE%\Core-Model\model\libs\Edu.Wisc.Forest.Flel.Util.dll)
* Metadata
	- Remove broken references
        + Landis.Core
        + Landis.SpatialModeling
	- Add project references to
		+ Core project
		+ Landis_SpatialModeling project
* output-cohort-stats
	- Remove broken references
		+ Edu.Wisc.Forest.Flel.Util
        + Landis.Core
        + Landis.Library.AgeOnlyCohorts
        + Landis.Library.Cohorts
        + Landis.Library.Metadata
        + Landis.SpatialModeling
	- Add project references to
		+ Core project
		+ age cohort project
		+ Metadata project
		+ Landis_SpatialModeling project
    - Add direct path DLL reference to
		+ Landis.Library.Cohorts (%LANDISII\_SOURCE%\Core-Model\model\libs\Landis.Library.Cohorts.dll)
		+ Edu.Wisc.Forest.Flel.Util.dll (%LANDISII\_SOURCE%\Core-Model\model\libs\Edu.Wisc.Forest.Flel.Util.dll)
* site-harvest-lib
	- Remove broken references
		+ Edu.Wisc.Forest.Flel.Util
        + Landis.Core
        + Landis.Library.AgeOnlyCohorts
        + Landis.Library.Cohorts
        + Landis.Library.Succession-v5
        + Landis.SpatialModeling
        + log4net
	- Add project references to
		+ Core project
		+ age cohort project
		+ library-succession project
		+ Landis_SpatialModeling project
    - Add direct path DLL reference to
		+ Landis.Library.Cohorts (%LANDISII\_SOURCE%\Core-Model\model\libs\Landis.Library.Cohorts.dll)
		+ Edu.Wisc.Forest.Flel.Util.dll (%LANDISII\_SOURCE%\Core-Model\model\libs\Edu.Wisc.Forest.Flel.Util.dll)
	- Add NuGet package reference to
		+ log4net

Once all reference dependencies are properly configured, rebuild the entire solution and ensure that all project builds are successful: right click `solution --> Rebuild Solution`.

## Step 4: Add Extensions to Core

The LANDIS-II core keeps track of installed extensions via a XML file, extensions.xml. To add all built extensions to extensions.xml, run the following commands in the command prompt:   

    > %LANDISII_SOURCE%\Core-Model\model\build\Debug\Landis.Extensions.exe add "%LANDISII_SOURCE%\Extension-Age-Only-Succession\deploy\installer\AgeOnly Succession 4.1.txt"
    > %LANDISII_SOURCE%\Core-Model\model\build\Debug\Landis.Extensions.exe add "%LANDISII_SOURCE%\Extension-Base-Wind\deploy\installer\Base Wind 2.2.txt" 
    > %LANDISII_SOURCE%\Core-Model\model\build\Debug\Landis.Extensions.exe add "%LANDISII_SOURCE%\Extension-Base-BDA\deploy\installer\Base BDA 3.0.1.txt"
    > %LANDISII_SOURCE%\Core-Model\model\build\Debug\Landis.Extensions.exe add "%LANDISII_SOURCE%\Extension-Base-Fire\deploy\installer\Base Fire 3.1.txt"
    > %LANDISII_SOURCE%\Core-Model\model\build\Debug\Landis.Extensions.exe add "%LANDISII_SOURCE%\Extension-Base-Harvest\deploy\installer\Base Harvest 3.1.txt"
    > %LANDISII_SOURCE%\Core-Model\model\build\Debug\Landis.Extensions.exe add "%LANDISII_SOURCE%\Extension-Output-Max-Species-Age\deploy\installer\Output MaxSpeciesAge 2.1.txt"
    > %LANDISII_SOURCE%\Core-Model\model\build\Debug\Landis.Extensions.exe add "%LANDISII_SOURCE%\Extension-Output-Cohort-Statistics\deploy\installer\Output Cohort Statistics 2.2.txt"
    
In addition to adding the extensions to extensions.xml, a reference dependency for each extension must be added to the Console project so that extension DLLs are available at runtime. Right click Console project References --> Add Reference --> Projects tab --> check the following extension projects:

* age-only-succession
* base-BDA
* base-fire
* base-harvest
* base-wind
* max-species-age
* output-cohort-stats

## Step 5: Run example scenario

We will now configure the Console project to run the [Age Only Succession scenario](https://github.com/LANDIS-II-Foundation/Extension-Age-Only-Succession/tree/master/deploy/examples). Open the Debug properties tab: Right click `Console project --> Properties --> Debug tab`. Browse to and set the following working directory:

	%LANDISII_SOURCE%\Extension-Age-Only-Succession\deploy\examples\

Add "scenario_s1e1.txt" as the command line argument.

The Console project is now configured to run and debug the example scenario. To run/debug the scenario, right click `Console project --> Debug --> Start new instance`. Ensure that the run completes and is successful. If you are unfamiliar with setting breakpoints and using the debugger please see the [Visual Studio debugger instructions](https://docs.microsoft.com/en-us/visualstudio/debugger/debugger-feature-tour). 
