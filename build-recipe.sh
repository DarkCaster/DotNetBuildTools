#!/bin/bash

recipe="$1"

script_dir="$( cd "$( dirname "$0" )" && pwd )"

. "$script_dir"/service-funcs.sh.in

[[ -z $recipe ]] && log "You must pass recipe file as parameter. This script is not intended to be run as standalone - use prepare-and-build.sh script instead" && exit 1

[[ ! -f $recipe ]] && log "Recipe file $recipe is not available, exiting" && exit 1

log "Loading $recipe recipe"

. "$recipe"
check_error

[[ -z $sources ]] && log "Recipe does not have \"sources\" parameter!" && exit 1
[[ -z $targets ]] && log "Recipe does not have \"targets\" parameter!" && exit 1

#sources as array
sources=( $sources )

#sources as array
targets=( $targets )

#files as array
files=( $files )

#create temp directory
temp_dir="$script_dir/temp"
tools_dir="$temp_dir/tools"
cake_exe="$tools_dir/cake/Cake.exe"

#add tools_dir to PATH
export PATH="$tools_dir:$PATH"

temp_dir=`2>/dev/null mktemp -t build.XXXXXX -d -p "$temp_dir"`
[[ -z $temp_dir || ! -d $temp_dir ]] && log "Failed to create temp_dir, exiting" && exit 1

cleanup () {
  log "Cleaning up $temp_dir dir"
  rm -rf "$temp_dir"
}

check_error_cleanup () {
  if [[ $? != 0 ]]; then
    log "Error detected while building $recipe"
    cleanup
    exit 1
  fi
}

#copy extra files and patches
for el in "${files[@]}"
do
  log "Copying $el file to build dir"
  cp "$el" "$temp_dir"
  check_error_cleanup
done

#process sources
for src in "${sources[@]}"
do
  #copy or extract source tree
  if [[ -f $src.zip ]]; then
    log "Extracting $src.zip to build dir"
    unzip -q "$src.zip" -d "$temp_dir"
    check_error_cleanup
  elif [[ -d $src ]]; then
    log "Copying $src to build dir"
    cp -r "$src" "$temp_dir"
    check_error_cleanup
  else
    log "$src source not found! exiting"
    cleanup
    exit 1
  fi
  #copy build script
  if [[ -f $src.cake ]]; then
    log "Copying $src.cake file to build dir"
    cp "$src.cake" "$temp_dir/build.cake"
    check_error_cleanup
  else
    log "Cake build script $src.cake not found! exiting"
    cleanup
    exit 1
  fi
  #run cake
  olddir="$PWD"
  cd "$temp_dir"
  log "Running $src.cake build script"
  CAKE_PATHS_TOOLS="$tools_dir" mono "$cake_exe"
  if [[ $? != 0 ]]; then
    log "Build failed!"
    cd "$olddir"
    cleanup
    exit 1
  fi
  cd "$olddir"
#done processing sources
done

#create output dir
if [[ ! -d dist ]]; then
  log "Creating dist dir"
  mkdir -p "dist"
  check_error_cleanup
fi

#process targets
for tgt in "${targets[@]}"
do
  #copy target to output dir
  if [[ -d $temp_dir/$tgt ]]; then
    log "Copying $temp_dir/$tgt dir contents to dist dir"
    cp "$temp_dir/$tgt"/* dist
    check_error_cleanup
  elif [[ -f $temp_dir/$tgt ]]; then
    log "Copying $temp_dir/$tgt file to dist dir"
    cp "$temp_dir/$tgt" dist
    check_error_cleanup
  else
    log "Build results at $temp_dir/$tgt is not found, exiting"
    cleanup
    exit 1
  fi
#done processing targets
done

log "Build of $recipe recipe is complete"
cleanup
exit 0
