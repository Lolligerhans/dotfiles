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

declare -gr cache_path="$dotfiles/scripts/.cache/";

# Ensuring version even if included already
load_version "$dotfiles/scripts/version.sh" 0.0.0;
#load_version "$dotfiles/scripts/assert.sh" 0.0.0;
load_version "$dotfiles/scripts/bash_meta.sh" 0.0.0;
#load_version "$dotfiles/scripts/boilerplate.sh" 0.0.0;
#load_version "$dotfiles/scripts/cache.sh" 0.0.0;
#load_version "$dotfiles/scripts/error_handling.sh" 0.0.0;
load_version "$dotfiles/scripts/fileinteracts.sh" 0.0.0;
#load_version "$dotfiles/scripts/git_utils.sh" 0.0.0;
#load_version "$dotfiles/scripts/progress_bar.sh" 0.0.0;
#load_version "$dotfiles/scripts/setargs.sh" 0.0.0;
#load_version "$dotfiles/scripts/termcap.sh" 0.0.0;
#load_version "$dotfiles/scripts/utils.sh" 0.0.0;

# Prints "true" if called with this NAME for the first time that day. NAME must
# contain only filename-able characters.
# Other output is simply redirected to stderr.
# Better to /dev/null❔
#
#   cache_daily NAME [ACTION=set]
#     ACTION
#       get:   Only output, do not update status
#       set:   Output and set status
#       reset: Output and reset status
#       wipe:  Output and resets ALL daily names.
#     The output corresponds to the state BEFORE the action.
cache_daily()
{
  declare name="${1:?cache_daily: Missing name}";
  declare action="${2:-set}";
  declare should_repeat;

  declare current_day;
  current_day="$(date -I)";

  declare cache_file;
  cache_file="${cache_path}/daily_${name}";
  if [[ ! -f "$cache_file" ]]; then
    should_repeat="true";
  else
    declare file_content;
    file_content="$(<"$cache_file")";
    # ISO format can be compared lexicographically: 2024-01-01 < 2024-01-02
    if [[ "$file_content" < "$current_day" ]]; then
      should_repeat="true";
    else
      should_repeat="false";
    fi
    # Sanity check linear time
    if [[ "$file_content" > "$current_day" ]]; then
      errchow "$FUNCNAME: File $cache_file from future date $file_content";
    fi
  fi
  printf "%s" "$should_repeat"; # Only output of this function

  1>&2 ensure_directory "$cache_path";
  case "$action" in
    get)
      ;;
    set)
      printf "%s" "${current_day}" >"${cache_file}";
      ;;
    reset)
      1>&2 rm -vf -- "$cache_file";
      ;;
    wipe)
      errchot "Remove the -v from this 'rm' command?";
      1>&2 rm -vf -- "$cache_path/daily_"*;
      ;;
    *)
      abort "Invalid action [$action]";
      ;;
  esac
}

cache_clear()
{
  rm -vrf "$cache_path/*";
  echok "Cleared cache";
}
