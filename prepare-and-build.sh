#!/bin/bash

recepies_dir="$1"

script_dir="$( cd "$( dirname "$0" )" && pwd )"

. "$script_dir"/service-funcs.sh.in

#clear log
clear_log

if [ "z$recepies_dir" = "z" ]; then
 log "Recepies dir not specified. Only preparing build tools and env."
else
 if [ -d "$recepies_dir" ]; then
  log "Attempting to build recepies at $recepies_dir"
 else
  log "Error: recepies dir at $recepies_dir does not exist"
  exit 1
 fi
fi

#temp dir
temp_dir="$script_dir/temp"
tools_dir="$temp_dir/tools"

nuget_dir="$tools_dir/nuget"
nuget_exe="$nuget_dir/nuget.exe"
nuget_exe_dist="$script_dir/dist/nuget/nuget-3.4.4.exe"


cake_dir="$tools_dir/cake"
cake_exe="$cake_dir/Cake.exe"
cake_dist="$script_dir/dist/cake/Cake-bin-v0.13.0.zip"

if [ ! -d "$temp_dir" ]; then
 log "Creating temp dir at $temp_dir"
 mkdir -p $temp_dir
 check_error
fi

if [ ! -d "$tools_dir" ]; then
 log "Creating tools dir at $tools_dir"
 mkdir -p $tools_dir
 check_error
fi

if [ ! -f "$nuget_exe" ]; then
 log "Creating nuget dir at $nuget_dir"
 mkdir -p $nuget_dir
 check_error
 log "Copying nuget exe from $nuget_exe_dist"
 cp "$nuget_exe_dist" "$nuget_dir/nuget.exe"
 check_error
fi


if [ ! -f "$cake_exe" ]; then
 log "Creating cake dir at $cake_dir"
 mkdir -p $cake_dir
 check_error
 log "Extracting cake dist from $cake_dist"
 unzip -q "$cake_dist" -d "$cake_dir"
 check_error
fi

if [ "z$recepies_dir" = "z" ]; then
 log "Exiting"
 exit 0
fi

olddir="$PWD"
cd "$recepies_dir"
check_error

while read recipe
do
 test "z$recipe" = "z" && break
 log "Processing $recipe"
 "$script_dir/build-recipe.sh" "$recipe"
 if [ "z$?" != "z0" ]; then
  log "Failed to build $recipe recipe"
  cd "$olddir"
  exit 1
 fi
done <<< "$(find . -iname '*.recipe' -type f)"

cd "$olddir"
check_error

