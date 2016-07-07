#!/bin/bash

script_dir="$( cd "$( dirname "$0" )" && pwd )"

. "$script_dir"/service-funcs.sh.in

#clear log
clear_log

#temp dir
temp_dir="$script_dir/temp"
tools_dir="$temp_dir/tools"

nuget_dir="$temp_dir/tools/nuget"
nuget_exe="$nuget_dir/nuget.exe"
nuget_exe_dist="$script_dir/dist/nuget/nuget-3.4.4.exe"


cake_dir="$temp_dir/tools/cake"
cake_exe="$temp_dir/tools/cake/Cake.exe"
cake_dist="$script_dir/dist/cake/Cake-bin-v0.13.0.zip"

if [ ! -d "$temp_dir" ]; then
 log "creating temp dir at $temp_dir"
 mkdir -p $temp_dir
 check_error
fi

if [ ! -d "$tools_dir" ]; then
 log "creating tools dir at $tools_dir"
 mkdir -p $tools_dir
 check_error
fi

if [ ! -f "$nuget_exe" ]; then
 log "creating nuget dir at $nuget_dir"
 mkdir -p $nuget_dir
 check_error
 log "copying nuget exe from $nuget_exe_dist"
 cp "$nuget_exe_dist" "$nuget_dir/nuget.exe"
 check_error
fi


if [ ! -f "$cake_exe" ]; then
 log "creating cake dir at $cake_dir"
 mkdir -p $cake_dir
 check_error
 log "extracting cake dist from $cake_dist"
 unzip -q "$cake_dist" -d "$cake_dir"
 check_error
fi

