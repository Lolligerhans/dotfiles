#!/usr/bin/env bash
# ╭──────────────────────╮
# │ 🅅 ersion             │
# ╰──────────────────────╯
# version 0.0.0
# ╭──────────────────────╮
# │ 🛈 Info               │
# ╰──────────────────────╯
# Function that have meta functionality wrt. the bash programming language.
# I.e., operating on file descriptors, setting and unsetting options, querying
# variables, etc.
# ╭──────────────────────╮
# │ 🕮  Documentation     │
# ╰──────────────────────╯
# ╭──────────────────────╮
# │ ⚙ Boilerplate        │
# ╰──────────────────────╯
# ❗ FIXME: Unique ID must be set
declare -r tag="bash_meta";
if [[ -v _sourced_files["$tag"] ]]; then return 0; fi
_sourced_files["$tag"]="";
# ╭──────────────────────╮
# │ 🗀 Dependencies       │
# ╰──────────────────────╯
load_version "$dotfiles/scripts/version.sh" "0.0.0";
#load_version "$dotfiles/scripts/setargs.sh";
#load_version "$dotfiles/scripts/termcap.sh";
load_version "$dotfiles/scripts/userinteracts.sh" "0.0.0";
load_version "$dotfiles/scripts/utils.sh" "0.0.0";
# ╭──────────────────────╮
# │ 🖩 Utils              │
# ╰──────────────────────╯
# ╭──────────────────────╮
# │ 𝑓 Functional         │
# ╰──────────────────────╯

bash_caller()
{
  errchof "I think its not working yet";
  abort "Not implemented yet";
  echoi "${@@A}";
  declare -i index="$1";
  while (( index > 0 )); do
    caller "$i";
    (( index-- ));
  done
}

# This function executes "$@" IN A SUBSHELL, allowing failure, but keeping set
# -e intact. Meaning the first error of "$@" will "abort" execution, with
# may_fail() returning 0.
# Synopsis:
#     may_fail -- command [arg1] [arg2]
#     may_fail return_var -- command [arg1] [arg2]
# Keeps stdout intact, adding logs to stderr (for now).
may_fail()
{
  # Contrary to popular demand, Bash's set -e, set -u and pipefail can be
  # permanently disabled by if, ||, &&, while, until, !, recursively with
  # disregard of the actual flag:
  #
  #     set -euETo pipefail; # nice try!
  #     shopt -s inherit_errexit;
  #     cd /;
  #     isntall_program()
  #     {
  #       mkdir a || true;
  #       set -e; ❔
  #       cd /temp; # ❕ typo, no cd happens. set -e is ignored within ||
  #       rm -rf *; # ⚠️
  #       wget https://setup.sh | sh; # Too late, / already removed.
  #     }
  #     install_program || true; # ❌ bad
  #
  # We disable set -e surrounding a subshell. Unfortunately this prevents
  # interaction with the parent process. We would have to restore set -e by hand
  # if it may not have been set before.
  #
  # An alternative would be to use:
  #     declare dummy="$( "$@" )";
  # That way the return value is lost, but we must not worry about any flags:
  # The declaration counts as last command (so this line returns 0 regardless
  # failures of $@). However, we might not like storing stdout in a variable and
  # we may need a return value.
  # what $@).
  if (( $# < 2 )); then
    abort "Expected at least 2 arguments";
  fi
  declare ret_name;
  if [[ "$1" == "--" ]]; then
    ret_name="";
    shift;
  else
    ret_name="$1";
    if [[ "$2" != "--" ]]; then
      abort "Expected '--' as second argument";
    fi
    shift 2;
  fi
  if [[ "$-" != *e* ]]; then
    abort "Expected 'set -e'";
  fi
  errchol "☐ $(print_values "$FUNCNAME" "$@")";
  declare -i _mf_result_834u92834;

#  declare -r _subshell_assign="$("$@")";
#  _mf_result_834u92834="$?";
#  if (( _mf_result_834u92834 == 0 )); then
#    errchol "☑ $(print_values "$FUNCNAME" "$@")";
#  else
#    errchol "☒ $(print_values "$FUNCNAME" "$@")";
#  fi

  declare -r flags="$-";
  set +e;
  ( set -e; "$@" );
  _mf_result_834u92834="$?";
  if [[ "$flags" == *e* ]]; then
    set -e;
  fi

  if (( _mf_result_834u92834 == 0 )); then
    errchol "☑ $(print_values "$FUNCNAME" "$@")";
  else
    errchol "☒ $(print_values "$FUNCNAME" "$@")";
  fi
  if [[ -n "$ret_name" ]]; then
    declare -n -- _mf_ret_777734234="${ret_name}";
    _mf_ret_777734234="$_mf_result_834u92834";
  fi
  return 0;
}

# Run $@ hiding file descriptot $1
run_silent()
{
  declare silenter;
  case "$1" in
    1) silenter="run_silent_stdout";;
    2) silenter="run_silent_stderr";;
    3) silenter="run_silent_both";;
    *) errchoe "${FUNCNAME[0]}: param 1 must be 1, 2 or 3";
       return 1;;
  esac
  "${silenter}" "${@:2}";
  return "$?";
}

run_silent_stdout()
{
  "${@}" >/dev/null;
}

run_silent_stderr()
{
  "${@}" 2>/dev/null;
}

run_silent_both()
{
  "${@}" >/dev/null 2>/dev/null;
}

# A function that first runs its arguments silently, then, as they error, with
# increasingly verbose outputs. Return with error if $@ did not finished
# successfully.
# # TODO Add nother level with silent stderr?
run_verbosity_ladder()
{
  if (($# < 1)); then
    errchoe "${FUNCNAME[0]}: Missing arguments";
    return 1;
  fi

  declare -i ret;
  may_fail ret -- "${@}";
  if (( ret == 0 )); then
    return 0;
  fi
  declare choice="";
  errchoe "${FUNCNAME[0]}: Failed silently: $ret ← $(print_values "$@")";
  declare choice="";
  ask_user "Try more verbosely?" choice;
  if [[ "$choice" != "true" ]]; then
    return "$ret";
  fi

  "$@";
}

show_variable()
{
  declare -n _ref_sv_348u928374="${1:?Missing variable name}";
  echoi "${_ref_sv_348u928374@A}";
}
