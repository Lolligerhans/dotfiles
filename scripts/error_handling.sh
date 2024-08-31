#!/usr/bin/env bash

# version 0.0.0

# shellcheck disable=2015

declare -r tag="error_handling";
if [[ -v _sourced_files["$tag"] ]]; then
  return 0;
fi
_sourced_files["$tag"]="";

# Ensuring version even if included already
load_version "$dotfiles/scripts/version.sh" 0.0.0;
#load_version "$dotfiles/scripts/assert.sh" 0.0.0;
satisfy_version "$dotfiles/scripts/boilerplate.sh" 0.0.0; # _sourced_files must be available
#load_version "$dotfiles/scripts/cache.sh" 0.0.0;
#load_version "$dotfiles/scripts/error_handling.sh" 0.0.0;
#load_version "$dotfiles/scripts/git_utils.sh" 0.0.0;
#load_version "$dotfiles/scripts/progress_bar.sh" 0.0.0;
#load_version "$dotfiles/scripts/setargs.sh" 0.0.0;
load_version "$dotfiles/scripts/termcap.sh" 0.0.0;
load_version "$dotfiles/scripts/utils.sh" 0.0.0;

declare -gri debug_error_routine=0; # Set by hand to debug

# ┌────────────────────────┐
# │ ⚙ Config               │
# └────────────────────────┘

declare -gr _error_handling_frames=4;

# ┌────────────────────────┐
# │ Error handling         │
# └────────────────────────┘

report_error()
{
  # Read runscript config if there is one
  if [[ -v _run_config["error_frames"] ]]; then
    declare -ir error_frames="${_run_config["error_frames"]}";
  else
    declare -ir error_frames="$_error_handling_frames";
  fi

  # If we set it before we no longer need it
  set +vx;

  #TODO Use nameref variables to capture context from actual error

  if (($1 == 0)); then
    errcho "$text_bold${text_yellow}report_error: Executed with exit code 0. Stopping error routine.$text_normal";
    errchot "Implement other signals";
    # TODO What to do here?
    return 33; # Arbitrary
  fi

  if ((debug_error_routine)); then
    errchoi "$text_bold ---------------------------- $text_normal";
    errchoi "(pwd: $(pwd))";
    cd "$parent_path" || errchoe "${FUNCNAME[0]}: Failed to 'cd' to parent_path";
    errchoi "pwd: $(pwd)";
    errchoi "FUNCNAME     [${#FUNCNAME[@]}]: ${FUNCNAME[*]}";
    errchoi "BASH_SOURCE  [${#BASH_SOURCE[@]}]: ${BASH_SOURCE[*]}";
    errchoi "BASH_LINENO  [${#BASH_LINENO[@]}]: ${BASH_LINENO[*]}";
    errchoi "BASH_COMMAND [ ]: ${BASH_COMMAND}";
    errchoi "Args:"
    errchoi " 1. code: $1";
    errchoi " 2. line: $2";
    errchoi " 3. file: $3";
    errchoi " 4. cmnd: $4";
    errchoi "$text_bold ---------------------------- $text_normal";
  fi

  cd "$parent_path" || errchoe "${FUNCNAME[0]}: Failed to 'cd' to parent_path";

  # Print failed command
  # TODO Use $4 (?) for command?
  errchoe              "Command ${text_lightred}${BASH_COMMAND}${text_normal}"\
    "exited with code" "${text_br}$1${text_normal}"\
    "in file"          "${text_dim}${text_italic}${3}${text_noitalic}:${2}${text_normal}"\
    "after ${text_bi}${SECONDS}${text_normal} seconds"\
    "at ${text_di}$(date -Iseconds)${text_normal}";

  # Print stack strace
  # TODO Use BASH_SUBSHELL to print only 1 frame in all non-last scrpts
  for ((i = 1; i < (${#FUNCNAME[@]} < error_frames ? ${#FUNCNAME[@]} : error_frames); i++))
  {
    # FIXME Does this not work for some cases?
    #declare s="$(basename "${BASH_SOURCE[$i]}")";
    # We need to keep the base dir to debug utils helper functions
    # TODO What do we need to strip the base dir for?
    declare s="${BASH_SOURCE[$i]}";
    declare -i l="${BASH_LINENO[$i-1]}";
    declare f="${FUNCNAME[$i]}";
    # Print executed line with +-3 liens context
    # TODO BASH_ARGV / BASH_ARGC: get args of functions
    # (!) We let the text_dim fallthrough to the text files a bunch
    ((debug_error_routine)) && errchod "Opening file $text_dim$s$text_normal from $text_dim$PWD$text_normal" || :;
    errcho " $text_di$text_blp${s}$text_noitalic:$l$text_normal $text_dim($text_blp$f$text_normal$text_dim)$text_normal";
    errcho -n "$text_dim";
    ((min = l-3 > 1 ? l-3 : 1 ));
    ((max = l + 3 ));
    ((mid = l - min + 1 ));
    #sed -ne "$min,$max=" -e "$min,${max}p" "$parent_path/$s" | \
    #sed -ne "$min,$max=" -e "$min,${max}p" "$s" | \
    sed -ne "$min,$max{=;p}" "$s" | \
    sed -e 's/^/       /' \
        -e 'N' \
        -e 's/^ *\(......\)\n/\1  /' | \
    sed -e 's/^/  /' -e "${mid}s/^  \(.*\)/ >$text_blr\1$text_normal$text_dim/"\
        1>&2;
    errcho -n "$text_normal";
  };

  return 0;
}
