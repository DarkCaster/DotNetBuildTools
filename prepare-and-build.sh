#!/bin/bash

recipes_dir="$1"

script_dir="$( cd "$( dirname "$0" )" && pwd )"

. "$script_dir"/service-funcs.sh.in

#clear log
clear_log

if [[ -z $recipes_dir ]]; then
  log "recipes dir not specified. Only preparing build tools and env."
else
  if [[ -d $recipes_dir ]]; then
    log "Attempting to build recipes at $recipes_dir"
  else
    log "Error: recipes dir at $recipes_dir does not exist"
    exit 1
  fi
fi

#temp dir
temp_dir="$script_dir/temp"
tools_dir="$temp_dir/tools"

nuget_dir="$tools_dir/nuget"
nuget_exe="$nuget_dir/nuget.exe"
nuget_exe_dist="$script_dir/dist/nuget/nuget-4.1.0.exe"


cake_dir="$tools_dir/cake"
cake_exe="$cake_dir/Cake.exe"
cake_dist="$script_dir/dist/cake/Cake-bin-net45-v0.19.5.zip"

if [[ ! -d $temp_dir ]]; then
  log "Creating temp dir at $temp_dir"
  mkdir -p $temp_dir
  check_error
fi

if [[ ! -d $tools_dir ]]; then
  log "Creating tools dir at $tools_dir"
  mkdir -p $tools_dir
  check_error
fi

if [[ ! -f $nuget_exe ]]; then
  log "Creating nuget dir at $nuget_dir"
  mkdir -p $nuget_dir
  check_error
  log "Copying nuget exe from $nuget_exe_dist"
  cp "$nuget_exe_dist" "$nuget_exe"
  check_error
fi


if [[ ! -f $cake_exe ]]; then
  log "Creating cake dir at $cake_dir"
  mkdir -p $cake_dir
  check_error
  log "Extracting cake dist from $cake_dist"
  unzip -q "$cake_dist" -d "$cake_dir"
  check_error
fi

if [[ -z $recipes_dir ]]; then
  log "Exiting"
  exit 0
fi

cd "$recipes_dir"
check_error

for recipe in *.recipe
do
  [[ ! -f $recipe ]] && break
  log "Processing $recipe"
  "$script_dir/build-recipe.sh" "$recipe"
  if [[ $? != 0 ]]; then
    log "Failed to build $recipe recipe"
    exit 1
  fi
done
