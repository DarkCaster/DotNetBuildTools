#!/bin/bash

recepie="$1"

script_dir="$( cd "$( dirname "$0" )" && pwd )"

. "$script_dir"/service-funcs.sh.in

test ! -f "$recepie" && log "recepie file $recepie is not available, exiting" && exit 1

log "loading $recepie recepie"

. "$recepie"
check_error

test "z$src" = "z" && log "recepie file $recepie does not have src parameter" && exit 1
test "z$files" = "z" && log "recepie file $recepie does not have files parameter" && exit 1
test "z$tgt" = "z" && log "recepie file $recepie does not have tgt parameter" && exit 1

#files as array
files=( $files )

#create temp directory
temp_dir="$script_dir/temp"
tools_dir="$temp_dir/tools"
cake_exe="$tools_dir/cake/Cake.exe"

#add tools_dir to PATH
export PATH="$tools_dir:$PATH"

temp_dir=`mktemp -t build.XXXXXX -d -p "$temp_dir"`
test ! -d "$temp_dir" && log "failed to create temp_dir, exiting" && exit 1

cleanup () {
 log "cleaning up"
 rm -rfv "$temp_dir"
}

check_error_cleanup () {
if [ "$?" != "0" ]; then
 log "error detected while building $recepie"
 cleanup
 exit 1
fi
}

#copy or extract source tree
if [ -f "$src.zip" ]; then
 log "extracting $src.zip to build dir"
 unzip -q "$src.zip" -d "$temp_dir"
 check_error_cleanup
else
if [ -d "$src" ]; then
 log "copying $src to build dir"
 cp -r "$src" "$temp_dir"
 check_error_cleanup
else
 log "$src source not found! exiting"
 cleanup
 exit 1
fi
fi

#copy build script
if [ -f "$src.cake" ]; then
 log "copying $src.cake file to build dir"
 cp "$src.cake" "$temp_dir/build.cake"
 check_error_cleanup
else
 log "cake build script $src.cake not found! exiting"
 cleanup
 exit 1
fi

#copy extra files and patches
for el in "${files[@]}"
do
 log "copying $el file to build dir"
 cp "$el" "$temp_dir"
 check_error_cleanup
done

#run cake
olddir="$PWD"
cd "$temp_dir"
 log "running $src.cake build script"
 CAKE_PATHS_TOOLS="$tools_dir" mono "$cake_exe"
 if [ "$?" != "0" ]; then
  log "build failed!"
  cd "$olddir"
  cleanup
  exit 1
 fi
cd "$olddir"

#create output dir
if [ ! -d "dist" ]; then
 log "creating dist dir"
 mkdir -p "dist"
 check_error_cleanup
fi

#copy target to output dir
if [ -d "$temp_dir/$tgt" ]; then
 log "copying $temp_dir/$tgt dir contents to dist dir"
 cp "$temp_dir/$tgt"/* dist
 check_error_cleanup
else
if [ -f "$temp_dir/$tgt" ]; then
 log "copying $temp_dir/$tgt file to dist dir"
 cp "$temp_dir/$tgt" dist
 check_error_cleanup
else
 log "build results at $temp_dir/$tgt is not found, exiting"
 cleanup
 exit 1
fi
fi

log "build of $recepie recepie is complete"
cleanup
exit 0

