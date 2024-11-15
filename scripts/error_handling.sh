#!/usr/bin/env bash

# version 0.0.0

# shellcheck disable=SC2015

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

declare -gri _error_handling_frames=99;
declare -gri _error_handling_skipnoise=0;
declare -gr _error_handling_noisepattern="@(command_run|command_rundir|command_runscript|subcommand|main)";

# ┌────────────────────────┐
# │ Error handling         │
# └────────────────────────┘

# - $1: exit code
# - $2: line number
# - $3: file
# - $4: command
report_error()
{
  # Read runscript config if there is one
  if [[ -v _run_config["error_frames"] ]]; then
    declare -ir error_frames="${_run_config["error_frames"]}";
  else
    declare -ir error_frames="$_error_handling_frames";
  fi
  if [[ -v _run_config["error_skipnoise"] ]]; then
    declare -ir error_skipnoise="${_run_config["error_skipnoise"]}";
  else
    declare -ir error_skipnoise="$_error_handling_skipnoise";
  fi

  # If we set it before we no longer need it
  set +vx;

  declare -ir error_code="${1:?Missing error code}";
  declare -ir error_line="${2:?Missing error line}";
  declare -r _error_file="${3:?Missing error file}";
  declare -r error_cmnd="${4:?Missing error command}";

  declare -r error_file="${caller_path}/${_error_file}";

  #TODO Use nameref variables to capture context from actual error

  if (( error_code == 0)); then
    errcho "$text_bold${text_yellow}report_error: Executed with exit code 0. Stopping error routine.$text_normal";
    errchot "Implement other signals";
    # TODO What to do here?
    return 33; # Arbitrary
  fi

  cd "$caller_path" || errchoe "${FUNCNAME[0]}: Failed to 'cd' to parent_path";

  if ((debug_error_routine)); then
    errchoi "$text_invert$text_bold <<<<<<<<<<<<<<<<<<<<<<<<<<<< $text_normal";
    show_variable PWD;
    show_variable parent_path;
    show_variable caller_path;
    errchoi "FUNCNAME     [${#FUNCNAME[@]}]: ${FUNCNAME[*]}";
    errchoi "BASH_SOURCE  [${#BASH_SOURCE[@]}]: ${BASH_SOURCE[*]}";
    errchoi "BASH_LINENO  [${#BASH_LINENO[@]}]: ${BASH_LINENO[*]}";
    errchoi "BASH_COMMAND [ ]: ${BASH_COMMAND}";
    errchoi "Args:"
    errchoi " 1. code: ${error_code}";
    errchoi " 2. line: $2";
    errchoi " 3. file: $3";
    errchoi " 4. cmnd: $4";
    errchoi "$text_invert$text_bold <<<<<<<<<<<<<<<<<<<<<<<<<<<< $text_normal";
  fi

  # Print failed command
  # TODO Use $4 (?) for command?
  errchoe              "Command ${text_lightred}${BASH_COMMAND}${text_normal}"\
    "exited with code" "${text_br}${error_code}${text_normal}"\
    "after ${text_bi}${SECONDS}${text_normal} seconds"\
    "at ${text_di}$(date -Iseconds)${text_normal}";
    #"in file"          "${text_dim}${text_italic}${3}${text_noitalic}:${2}${text_normal}"\

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
    # shellcheck disable=SC2053
    if (( error_skipnoise == 2 )) && [[ "$f" == $_error_handling_noisepattern ]]; then
      continue;
    fi
    # Print executed line with +-3 liens context
    # TODO BASH_ARGV / BASH_ARGC: get args of functions
    # (!) We let the text_dim fallthrough to the text files a bunch
    ((debug_error_routine)) && errchod "Opening file $text_dim$s$text_normal from $text_dim$PWD$text_normal" || :;
    errcho " $text_di$text_blp${s}$text_noitalic:$l$text_normal $text_dim($text_blp$f$text_normal$text_dim)$text_normal";
    # shellcheck disable=SC2053
    if (( error_skipnoise == 1 )) && [[ "$f" == $_error_handling_noisepattern ]]; then
      continue;
    fi
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
        1>&2 || echon "Use absolute paths to include files";
    errcho -n "$text_normal";
  };

  return 0;
}
