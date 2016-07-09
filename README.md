# .NetBuildTools

Some basic build scripts for use with my .NET C# projects. Main goal of this project is to provide some automation for building local (and, maybe, customized) nuget packages and dll's of common dependencies that I use in my projects. Use at your own risk, this scripts and tools may be unstable and not work as intended. You can freely reuse, change, or distribute almost any part of this project, see license file for details. Binary dependencies (for windows) used in this project may use its own licences and distribution rules, see license files in "dist" subfolders.

Currently supported platforms - msbuild (windows, powershell), and xbuild (mono, bash, linux or bsd).

How to use:

1. Create directory where you will store all sources of external dependencies and build scripts and "recipe" files (see examples dir)

2. Create "recipe" file, build script for cake build system, and place dep's source directory at the same level as recipe file. Source directories can be packed in zip archive. Cake build script must have the same name as source dir (example: for msgpack source dir (or msgpack.zip file) - cake build script must be named msgpack.cake)

3. Fillup recipe file (see msgpack example). You can select multiple source dirs to compile, multiple extra files to use (patches?), and multiple target result files or directories to copy back from source tree, when build complete

4. Run prepare-and-build.sh or prepare-and-build.bat (for windows), with parameter - path for your recipes folder (example: ./prepare-and-build.sh ./examples)

5. Build scripts use temporary dir for build and modifications to source tree. After build is complete resulting files will be copied back to "dist" dir inside your recipes directory (that passed to prepare-and-build as parameter)

