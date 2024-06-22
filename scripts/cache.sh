#!/usr/bin/env bash

# version 0.0.0

declare -r tag="cache";
if [[ -v _sourced_files["$tag"] ]]; then
  return 0;
fi
_sourced_files["$tag"]="";

# Cache helpers to interface usage of the .cache directory for things that are
# modularized and used in multiple places.
#
# Single-customer type use can just be implemented whereever needed.

# TODO Uclobber namespace
declare -gr cache_path="$dotfiles/scripts/.cache/";

# Ensuring version even if included already
load_version "$dotfiles/scripts/version.sh" 0.0.0;
#load_version "$dotfiles/scripts/assert.sh" 0.0.0;
#load_version "$dotfiles/scripts/boilerplate.sh" 0.0.0;
#load_version "$dotfiles/scripts/cache.sh" 0.0.0;
#load_version "$dotfiles/scripts/error_handling.sh" 0.0.0;
load_version "$dotfiles/scripts/fileinteracts.sh" 0.0.0;
#load_version "$dotfiles/scripts/git_utils.sh" 0.0.0;
#load_version "$dotfiles/scripts/progress_bar.sh" 0.0.0;
#load_version "$dotfiles/scripts/setargs.sh" 0.0.0;
#load_version "$dotfiles/scripts/termcap.sh" 0.0.0;
#load_version "$dotfiles/scripts/utils.sh" 0.0.0;

# Return "true" if called with this NAME for the first time that day.
#
#   cache_daily NAME [ACTION=set]
#     ACTION
#       get:   Only output, do not update status
#       set:   Output and set status
#       reset: Output and reset status
#       wipe:  Resets all names (!) Might delete other files by accident
cache_daily()
{
  declare name="${1:?cache_daily: Missing name}";
  declare action="${2:-set}";

  1>&2 ensure_directory "$cache_path";

  declare cache_file; cache_file="${cache_path}/daily_${name}_$(date -I)";
  if [[ -f "$cache_file" ]]; then
    declare has_file="false";
  else
    declare has_file="true";
  fi
  printf "%s" "$has_file";

  case "$action" in
    get)
      ;;
    set)
      1>&2 touch "$cache_file";
      ;;
    reset)
      1>&2 rm -v"$cache_file";
      ;;
    wipe)
      errchot "Remove the -v from the remove command?";
      1>&2 rm -v "$cache_path/daily_"*;
      ;;
    *)
      abort "cache_daily: Invalid action [$action]";
      ;;
  esac
}

cache_clear()
{
  rm -vrf "${dotfiles}/scripts/.cache/";
  echok "Cleared cache";
}
