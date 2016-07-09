param([string]$recipe="")

$script_dir = split-path -parent $MyInvocation.MyCommand.Definition

. "$script_dir\service-funcs.ps1"

if ( $recipe.Length -eq 0 )
{
    log "You must pass recipe file as parameter. This script is not intended to be run as standalone - use prepare-and-build.sh script instead"
    exit 1
}

log "Loading $recipe recipe"

$recipe_content=Get-Content "$recipe"
check_error

$sources=""
$targets=""
$files=""

foreach ($line in $recipe_content)
{
    $match = [regex]::Match($line,'^(.*)\=\"(.*)\".*$')
    if( ($match.Groups[1].value -ne "sources") -and ($match.Groups[1].value -ne "targets") -and ($match.Groups[1].value -ne "files") )
    {
        continue
    }
        
    if( ($match.Groups[1].value -ne "") -and ($match.Groups[2].value -ne "") )
    {
        Set-Variable -Name $match.Groups[1].value -Value $match.Groups[2].value
    }
}

if ( $sources -eq "" )
{
    log "Recipe does not have sources parameter"
    exit 1
}

if ( $targets -eq "" )
{
    log "Recipe does not have targets parameter"
    exit 1
}

$sources = $sources -split " "
$targets = $targets -split " "
$files = $files -split " "

$temp_dir="$script_dir\temp"
$tools_dir="$temp_dir\tools"
$cake_exe="$tools_dir\cake\Cake.exe"

$temp_dir = "$temp_dir" + "\build." + ("{0:d5}" -f (Get-Random)).Substring(0,5)

mkdir -Force "$temp_dir" | Out-Null
check_error

$curdir=Get-Location
$curdir_str=$curdir.ToString()

function cleanup ()
{
    log "Cleaning up $temp_dir dir"
    Remove-Item -Recurse -Force "$temp_dir" | Out-Null
}

function check_error_cleanup ()
{
    if(!($?))
    {
        log "Error detected while building $recipe"
        cleanup
        exit 1
    }
}

foreach ($file in $files)
{
    log "Copying $file file to build dir"
    cp "$file" "$temp_dir"
    check_error_cleanup
}

foreach ($src in $sources)
{

if(Test-Path -PathType Leaf "$curdir_str\$src.zip")
{
    log "Extracting $src.zip to build dir"
    unzip -File "$curdir_str\$src.zip" -Destination "$temp_dir"
    check_error_cleanup
}
elseif(Test-Path -PathType Container "$src")
{
    log "Copying $src to build dir"
    Copy-Item -Path "$src" -Destination "$temp_dir" -recurse -Force
    check_error_cleanup
}
else
{
    log "$src source not found! exiting"
    cleanup
    exit 1
}

if(Test-Path -PathType Leaf "$src.cake")
{
    log "Copying $src.cake file to build dir"
    cp "$src.cake" "$temp_dir/build.cake"
    check_error_cleanup
}
else
{
    log "Cake build script $src.cake not found! exiting"
    cleanup
    exit 1
}

cd "$temp_dir"
log "Running $src.cake build script"
$env:CAKE_PATHS_TOOLS="$tools_dir" 
& "$cake_exe"
if(!($?))
{
    log "Build failed!"
    Set-Location $curdir
    cleanup
    exit 1
}
Set-Location $curdir

}

if(!(Test-Path -PathType Container "$dist"))
{
    log "Creating dist dir"
    mkdir -Force "$dist" | Out-Null
    check_error_cleanup
}

foreach ($tgt in $targets)
{
    if(Test-Path -PathType Container "$temp_dir\$tgt")
    {
        log "Copying $temp_dir\$tgt dir contents to dist dir"
        Copy-Item -Path "$temp_dir\$tgt" -Destination "dist" -recurse -Force
        check_error_cleanup
    }
    elseif(Test-Path -PathType Leaf "$temp_dir\$tgt")
    {
        log "Copying $temp_dir\$tgt file to dist dir"
        cp "$temp_dir\$tgt" dist
        check_error_cleanup
    }
    else
    {
        log "Build results at $temp_dir\$tgt is not found, exiting"
        cleanup
        exit 1
    }
}

log "Build of $recipe recipe is complete"
cleanup
exit 0
