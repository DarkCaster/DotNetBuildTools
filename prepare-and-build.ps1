param([string]$recipes_dir="")

$script_dir = split-path -parent $MyInvocation.MyCommand.Definition

. "$script_dir\service-funcs.ps1"

clear_log

if ( $recipes_dir.Length -eq 0 )
{
    log "Recipes dir not specified. Only preparing build tools and env."
}
else
{
    if( Test-Path "$recipes_dir" )
    {
        log "Attempting to build recipes at $recipes_dir"
    }
    else
    {
        log "Error: recipes dir at $recipes_dir does not exist"
        exit 1
    }
}

$temp_dir="$script_dir\temp"
$tools_dir="$temp_dir\tools"

$nuget_dir="$tools_dir\nuget"
$nuget_exe="$nuget_dir\nuget.exe"
$nuget_exe_dist="$script_dir\dist\nuget\nuget-3.4.4.exe"

$cake_dir="$tools_dir\cake"
$cake_exe="$cake_dir\Cake.exe"
$cake_dist="$script_dir\dist\cake\Cake-bin-v0.13.0.zip"
$cake_extra="$script_dir\dist\roslyn"

$patch_dir="$tools_dir\patch"
$patch_exe="$patch_dir\patch.exe"
$patch_dist="$script_dir\dist\patch\patch.zip"

$unzip_dir="$tools_dir\unzip"
$unzip_exe="$unzip_dir\unzip.exe"
$unzip_exe_dist="$script_dir\dist\unzip\unzip.exe"

if(!(Test-Path "$temp_dir"))
{
    log "Creating temp dir at $temp_dir"
    mkdir -Force "$temp_dir" | Out-Null
    check_error
}

if(!(Test-Path "$tools_dir"))
{
    log "Creating tools dir at $tools_dir"
    mkdir -Force "$tools_dir" | Out-Null
    check_error
}

if(!(Test-Path -PathType Leaf "$unzip_exe"))
{
    log "Creating unzip dir at $unzip_dir"
    mkdir -Force "$unzip_dir" | Out-Null
    check_error
    log "Copying unzip exe from $unzip_exe_dist"
    cp "$unzip_exe_dist" "$unzip_dir\unzip.exe"
    check_error
}

$env:Path += ";$unzip_dir"

if(!(Test-Path -PathType Leaf "$nuget_exe"))
{
    log "Creating nuget dir at $nuget_dir"
    mkdir -Force "$nuget_dir" | Out-Null
    check_error
    log "Copying nuget exe from $nuget_exe_dist"
    cp "$nuget_exe_dist" "$nuget_dir\nuget.exe"
    check_error
}

if(!(Test-Path -PathType Leaf "$cake_exe"))
{
    log "Creating cake dir at $cake_dir"
    mkdir -Force "$cake_dir" | Out-Null
    check_error
    log "Extracting cake dist from $cake_dist"
    unzip -File "$cake_dist" -Destination "$cake_dir"
    check_error
    log "Copying cake addons from $cake_extra"
    Copy-Item "$cake_extra\*" "$cake_dir" -Filter "*.dll" -Recurse
    check_error
}

if(!(Test-Path -PathType Leaf "$patch_exe"))
{
    log "Creating patch dir at $patch_dir"
    mkdir -Force "$patch_dir" | Out-Null
    check_error
    log "Extracting patch dist from $patch_dist"
    unzip -File "$patch_dist" -Destination "$patch_dir"
    check_error
}

$env:Path += ";$patch_dir"

if ( $recipes_dir.Length -eq 0 )
{
    log "Exiting"
    exit 0
}

$curdir=Get-Location

cd "$recipes_dir"
check_error

$recipes=Get-ChildItem -File -Filter *.recipe | Sort-Object name

ForEach ($recipe in $recipes)
{
    log "Processing $recipe"
    & "$script_dir\build-recipe.ps1" $recipe.Name
    if(!($?))
    {
        log "Failed to build $recipe recipe"
        Set-Location $curdir
        exit 1
    }
}

Set-Location $curdir
check_error
