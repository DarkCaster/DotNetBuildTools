var target = Argument("target", "Default");
var configuration = Argument("configuration", "Release");
var buildDir = Directory("msgpack/bin/net452");

Task("Clean").Does(() => { CleanDirectory(buildDir); });

Task("Restore-NuGet-Packages").IsDependentOn("Clean").Does(() => { NuGetRestore("msgpack/MsgPack.sln"); });

Task("Build").IsDependentOn("Restore-NuGet-Packages").Does(() =>
{
 if(IsRunningOnWindows())
 {
  MSBuild("msgpack/MsgPack.sln", settings => settings.SetConfiguration(configuration).WithTarget("src\\_NET45\\MsgPack_Net45:Rebuild"));
 }
 else
 {
  XBuild("msgpack/MsgPack.sln", settings => settings.SetConfiguration(configuration).WithTarget("MsgPack_NET45:Rebuild"));
 }
});

Task("Pack").IsDependentOn("Build").Does(() =>
{
 var nuGetPackSettings   = new NuGetPackSettings
 {
  BasePath = "msgpack",
 };
 NuGetPack("msgpack/MsgPack.nuspec", nuGetPackSettings);
});

Task("Patch").Does(() =>
{
 var settings=new ProcessSettings()
 {
  WorkingDirectory = new DirectoryPath("msgpack"),
  Arguments = new ProcessArgumentBuilder().Append("-p1").Append("-i").Append("../msgpack-nuspec.patch"),
 };

 if(IsRunningOnWindows())
 { StartProcess("patch.exe",settings); }
 else
 { StartProcess("patch",settings); }
});

Task("Default").IsDependentOn("Pack");

RunTarget("Patch");
RunTarget(target);

