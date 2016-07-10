@echo off
set ScriptRoot=%~dp0
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='silentlycontinue'; Clear-Content -Path '%ScriptRoot%\prepare-and-build.ps1' -Stream 'Zone.Identifier'"
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='silentlycontinue'; Clear-Content -Path '%ScriptRoot%\build-recipe.ps1' -Stream 'Zone.Identifier'"
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='silentlycontinue'; Clear-Content -Path '%ScriptRoot%\service-funcs.ps1' -Stream 'Zone.Identifier'"

PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '%ScriptRoot%\prepare-and-build.ps1' %*"
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%

