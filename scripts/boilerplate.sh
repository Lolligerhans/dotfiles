#!/usr/bin/env bash

# version 0.0.0

if [[ ! -v _sourced_files["runscript"] ]]; then exit 3; fi
if [[ -v _sourced_files["boilerplate"] ]]; then
  return 0
fi
_sourced_files["boilerplate"]=""

################################################################################
# Info
################################################################################

# This script contains boilerplate and is sourced from a "runscript".
#
# The runscript MUST contain a small amount of setup command to communicate with
# this file. Start from snippets/runscript.sh and add your own code as commands.

################################################################################
# Bash settings
################################################################################

# TODO Use "not -v" or "-z"?
#if [[ ! -v "${BASH_SOURCE[0]}" ]]; then
#  echo "run.sh: Bash required";
#  exit 1;
#fi

# Identical to set -euETo pipefail
# If a subcommand/source file is allowed to fail, reset +eu flags temporarily.
set -o errexit -o nounset -o errtrace -o functrace -o pipefail
# Remember location of commands. I guess it could wreck things specificaly when
# these commands change?
set -h
shopt -s inherit_errexit
# Extended pattern matching. Example users:
#  - set_args
#  - update_alternatives
#  - version
shopt -s extglob
# Allow $'' within "${}"
shopt -s extquote
# Warn about shifting too far
shopt -s shift_verbose
# Use GNU error format. Probably only use this when parsing with a script
#shopt -s gnu_errfmt;
# TODO consider shopt -s lastpipe
# TODO consider shopt -s xpg_echo
IFS=$'\n\t'

# Remove warnings mannually if behaviour is intended
if [[ ! "${dotfiles}" -ef "${HOME}/dotfiles" ]]; then
  1>&2 printf "%s\n" "[!] Loading external dotfiles $dotfiles"
fi
if [[ -v DOTFILES ]]; then
  1>&2 printf "%s\n" "[!] Receiving from temporary dotfiles=$dotfiles"
fi
if [[ -z "${dotfiles}" ]] || ((${#dotfiles} < 5)); then
  1>&2 printf "%s\n" "[!] dotfiles='$dotfiles', aborting."
  exit 1
fi

# Always move to parent directory. Makes behaviour independent of caller's
# working directory.
declare -g caller_path parent_path
caller_path="$(pwd -P)"
cd "$(dirname -- "${1:?boilerplate.sh: missing BASH_SOURCE}")" # $1 must be set to ${BASH_SOURCE[0]} of run.sh
parent_path="$(pwd -P)"
declare -r caller_path parent_path
shift # Recover 'actual' args from the user of the runscript

declare -gA _run_config
_run_config=(
  # Set this to 1/0 to enable/disable file load logging, respectively. Some
  # older files will source things directly, so it would not have effect on
  # these files.
  ["log_loads"]=0

  # Use the declare_optionals config for setargs. Since there are predefined
  # commands, this option cannot be changed (unless those commadns are removed
  # or adjusted).
  # TODO: Deprecated. Remove this eventually
  ["declare_optionals"]=1 # {0,1} (1 is also the "default" value in setargs.sh)

  # Change number of frames printed in error handling. Can be be changed as
  # desired. Setting to 1 turns off framing (only shows error message).
  ["error_frames"]=2 # [1,inf)

  # In error handling, hide some boilerplate commands and functions.  Oneline is
  # a compromise to not hide the fact that the calls exists.
  ["error_skipnoise"]=2 # 0/1/2 for show/oneline/skip

  # Verify file versions when using 'load_version' and 'satisfy_version'. If
  # turned off, versions are assumed-ok always. Turn off to save on computation.
  ["versioning"]=0
)

# Enable versioning as early as possible
# shellcheck source=scripts/version.sh
source "$dotfiles/scripts/version.sh"
satisfy_version "$dotfiles/scripts/version.sh" 0.0.0

# Add our error trap as early as possible
trap 'report_error "${?}" "${LINENO}" "${BASH_SOURCE[0]}" "${BASH_COMMAND}"' \
  ERR ABRT TERM HUP

# Script info
declare -gra runscript_args=("$@")
declare -gr parent_path_coloured="${text_dim}${parent_path%/*}/${text_normal}${text_user_soft}${parent_path##*/}${text_normal}"
declare -gr runscript_path_coloured="${parent_path_coloured}/${0##*/}"
declare -gr runscript_relativepath_coloured="${text_user}${0%/*}/${text_normal}${text_dim}${0##*/}${text_normal}"

# TODO add versions required by the biolerplate stuff
load_version "$dotfiles/scripts/error_handling.sh" 0.0.0   # Test here because the traps are defined here as well
load_version "$dotfiles/scripts/run_help_strings.sh" 0.0.0 # TODO use source?
load_version "$dotfiles/scripts/setargs.sh" 0.0.0

# Ensuring version even if included already
#load_version "$dotfiles/scripts/assert.sh" 0.0.0;
#load_version "$dotfiles/scripts/cache.sh" 0.0.0;
#load_version "$dotfiles/scripts/git_utils.sh" 0.0.0;
#load_version "$dotfiles/scripts/progress_bar.sh" 0.0.0;
load_version "$dotfiles/scripts/termcap.sh" 0.0.0
load_version "$dotfiles/scripts/utils.sh" 3.0.0

# Log script entry and exit to stderr
_col() { if (($1)); then printf "%s" "$text_lightred"; else printf "%s" "$text_lightgreen"; fi; }
_sym() { if (($1)); then printf "✖"; else printf "✔"; fi; }

# Use syntax ${array[@]:0:1} which works for empty arrays, too
# shellcheck disable=SC2145
errchol "$text_blb$text_dim• •$text_normal $text_blb›(${runscript_relativepath_coloured} $(print_values_decorate "${text_user}${runscript_args[@]:0:1} ${text_normal}" "${text_dim}" "$text_user_soft" "${runscript_args[@]:1}")${text_blb})${text_normal} ${text_dim}⌂ $text_italic$parent_path$text_normal"
trap '_ret="$?"; _cval="$(_col "$_ret")"; errchol "$text_bold${_cval}$(_sym "$_ret") $_ret ‹(${runscript_relativepath_coloured} $(print_values_decorate "${text_user}${runscript_args[@]:0:1} ${text_normal}" "${text_dim}" "${text_user_soft}" "${runscript_args[@]:1}")${_cval}${text_bold})$text_normal $text_dim⌂ $text_italic$parent_path$text_normal";' \
  EXIT

################################################################################
# Predefined commands # TODO move to separate file?
################################################################################

# Show help strings
command_help() {
  set_args "--match=? --count=1 --all --help" "$@"
  eval "$get_args"

  # Obtain command list
  declare -i N="${count}"
  declare -a command_array
  declare -a command_array
  if [[ "$match" != "?" ]]; then
    mapfile -t command_array < <(subcommand print_commands "$match")
  else
    mapfile -t command_array < <(subcommand print_commands)
  fi
  if (("${#command_array[@]}" == 0)); then
    # Put in stderr to allow grepping for results on stdout
    errchon "${text_di}No matching commands${text_normal}"
    return 0
  fi

  # Determine longest for printing
  if ((N <= 1)); then
    declare i max_length=0
    declare -i i
    for ((i = 0; i < "${#command_array[@]}"; i++)); do
      ((max_length = ${#command_array[$i]} > max_length ? ${#command_array[$i]} : max_length))
    done
  fi

  # TODO This could accidentally trigger some commands
  #  if (( ${#command_array[@]} == 1 )); then
  #    subcommand "${command_array[0]}" "--help";
  #  else
  #  fi

  declare com var str buffer col tcol
  for com in "${command_array[@]}"; do
    var="${com}_help_string"
    declare str
    if [[ -v "$var" ]]; then # TODO better test for original help string?
      declare -n ref="$var"
      str="$(head "-$N" <<<"$ref")"
      # TODO We would like to print the usage string, but we currently have no
      #      convincing canonical way to get it from set_args without being
      #      awkward. Additionally, that would require to call the commands
      #      which they might not be intended for.
      #      usage="$(subcommand "$com" "--help")";
      #      usage="$(head -n1 <<< "$usage")";
    else
      str="$text_dim(no help available)$text_normal"
      #      usage="";
    fi

    # Reduce noise from predefined commands unless --all is given
    # TODO If dashes in function names make problems try this (add the
    # appropriate symbols that bash functions can use):
    #   (^|[^[:alnum:]_-]) instead of \< / [[:<:]]
    #   ([^[:alnum:]_-]|$) instead of \> / [[:>:]]
    # TODO Move to start of loop
    declare regex='\<'"$com"'\>'
    if [[ "$all" == "false" ]] && [[ "$predefined_commands" =~ $regex ]]; then
      continue
    fi

    if ((N <= 1)); then
      repeat_string "$((max_length - ${#com} + 2))" "…" buffer
      col="${text_user_soft}"
      tcol=""
    else
      buffer=" • "
      col="${text_user_hard}"
      tcol="${text_user_soft}"
    fi
    # Add a text_normal at end in caste strings contain ASNI escapes
    printf "%s\n" "${col}$com${text_normal}${text_dim}${buffer}${text_normal}${tcol}${str/$'\n'/"${text_normal}"$'\n'}${text_normal}"
  done
}

command_link_this() {
  # Because this_locaiton is set to "" by default, an argument will be required
  # unless the location is overwritten.
  set_args "--dir=$this_location --keep --help" "$@"
  eval "$get_args"

  # Sanity checks for user
  #  if [[ -a "$dir/run.sh" ]]; then
  #    errchow "Link target $dir/run.sh already exists!";
  #  fi
  #  if [[ -a "$dir/commands.sh" ]]; then
  #    errchow "Link target $dir/commands.sh already exists!";
  #  fi

  subcommand rundir "$dotfiles" deploy --yes --keep="$keep" "--file=$parent_path/run.sh" "--dir=$dir"
  #subcommand rundir "$dotfiles" deploy --yes --keep="$keep" "--file=$parent_path/commands.sh" "--dir=$dir";
  echok "Linked {run.sh commands.sh} $text_bold$parent_path$text_normal ➜ $text_bold$dir$text_normal"
}

command_quit() {
  exit 0
}

command_interactive() {
  set_args "--help" "$@"
  eval "$get_args"

  # TODO add additional "args" command to set args for next command
  errchot "No args command yet"

  #declare -r command_list=($(subcommand print_commands));
  declare -a command_list
  mapfile -t command_list < <(subcommand print_commands)
  declare chosen_command
  # Sort in an extra "drop" to drop the script arguments for follow-up commadns
  select chosen_command in "drop" "${command_list[@]}"; do
    case "$chosen_command" in
    # ❗Special handling of interactive sessions:
    #   • drop: Remove passed arguments from interactive session
    #   • interactive: Not allowed recursively from interactive
    drop)
      if (($# == 0)); then
        errchow "Already without arguments"
      else
        subcommand interactive # Without arguments
      fi
      ;;
    interactive)
      errchoe "Already in interactive mode"
      ;;
    quit)
      subcommand quit "$@" # Special case: $0 does not work for "quit"
      ;;
    *)
      # We use logging in interactive mode
      "$0" "$chosen_command" "$@"
      ;;
    esac
  done
}

# Execute script:     runscript <file>
# Execute from dir:   rundir <path>
# Auto:               run <path>
#                     run <file>
command_run() {
  declare name
  name="$(basename "${1:?Missing input parameter 1}")"
  if [[ "$name" == "run.sh" ]]; then
    subcommand runscript "$@"
  else
    subcommand rundir "$@"
  fi
}
command_rundir() {
  subcommand runscript "${1:?"${FUNCNAME[0]}: Missing input parameter 1"}/run.sh" "${@:2}"
}
command_runscript() {
  if (($# < 1)); then abort "Usage: $text_bi$0$text_normal runscript ${text_italic}path/script.sh$text_normal"; fi
  if [[ ! -e "$1" ]]; then abort "${FUNCNAME[0]}: No such file: $1"; fi

  command "$1" "${@:2}"
}

# Execute bash function that is part of the default includes
command_function() {
  # Use case for the new argv :)
  set_args "--name= -- --git --progress --cache --system --help" "$@"
  eval "$get_args"

  # TODO Maybe we should define variables for these files (?)
  if [[ "$git" == "true" ]]; then source "$dotfiles/scripts/git_utils.sh"; fi
  if [[ "$progress" == "true" ]]; then source "$dotfiles/scripts/progress_bar.sh"; fi
  if [[ "$cache" == "true" ]]; then source "$dotfiles/scripts/cache.sh"; fi
  if [[ "$system" == "true" ]]; then source "$dotfiles/scripts/system.sh"; fi

  "$name" "${argv[@]}"
}

#TODO Remove this? Not much helpful anymore, too much going on.
function command_debug() {
  bash -vx "$0" "${@}"
}

# Print list of available commands
# shellcheck disable=SC2120
command_print_commands() {
  if (("$#" == 0)); then
    # This part is used by the autocompletion for the "e" (execute) alias
    declare -a all_commands
    mapfile -t all_commands < <(declare -F | sed -ne 's/^declare -f command_\(\w\+\)/\1/p')
    echo "${all_commands[*]}"
  else
    # Replace \n in case the user has changed IFS # TODO?
    command_print_commands | sed -e 's/ /\n/g' | grep --color=auto -e "$1" || :
  fi
  return 0
}

# Completion verifier
# Takes name of a command WITHOUT prefix "command_" and outputs "true" when
# a help string exists, "false" otherwise.
# This is based on the convention that commmands use set_args fully when they
# specify a help string. It is needed to know if a function can safely be called
# with --completion without having to try the function itself.
# TODO Not used anywhere (!?)
command_has_completion() {
  declare -r cmd="${1:?"FUNCNAME: Missing input parameter 1"}"
  if [[ -v "${cmd}_help_string" ]]; then
    printf -- "true"
  else
    printf -- "false"
  fi
}

################################################################################
# Helper
################################################################################

# Allow implicit default command as special case
function subcommand() {
  if (($# == 0)); then
    # Run default when no arguments given so that runscript remains scriptable
    # in simple cases with only the default command.
    command_default

  elif [[ "${1:0:1}" == "-" ]]; then
    # Allow only passing "--help" (and other options) by implying default
    # command. Is more intuitive. We cannot start our command names with a dash.
    command_default "${@:1}"

  elif [[ "$(type -t "command_$1")" == "function" ]]; then
    # Pass rest of the arguments to subcommand
    "command_${1}" "${@:2}"

  else
    subcommand help "${@:1}"
    abort "Command not found: ${*:1}"
  fi
}

################################################################################
# Main
################################################################################

# Remember which commands are predefined to hide them in help. Separated by
# newlines.
# TODO Print commands into array to make it faster
declare -g predefined_commands
predefined_commands="$(subcommand print_commands)"
declare -r predefined_commands

# Enfore execution in directory "$this_location"
if [[ -v this_location ]] && [[ -n "$this_location" ]] && [[ ! "$this_location" -ef "$parent_path" ]]; then
  echou "This runscript wants to be in location $this_location, is at $parent_path"
  echon "Determined by setting 'this_location' in commands.sh"
  if [[ ! -f "$this_location/run.sh" ]]; then
    subcommand link_this --keep
  fi
  errchow "Continuing at $text_italic$this_location$text_noitalic!"
  subcommand rundir "$this_location" "$@"
  exit "$?"
fi

# Sanity checks
if ! shopt -qp extglob inherit_errexit; then
  # Many of the scripts use these
  abort "Expected 'extglob' and 'inherit_errexit' to be on"
fi
# We allow flags -hHxv to be either set or unset
if [[ "${-//[hHvx]/}" != "euBET" ]]; then
  errchoe "Flags: is=${-//[hHvx]/} should=euBET raw=${-}"
  abort "Expected safe bash flags: -euBET"
fi
