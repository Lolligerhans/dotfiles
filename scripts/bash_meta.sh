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

# This function executes "$@", allowing failure, but keeping set -e intact.
# Meaning the first error of "$@" will "abort" execution, returning 0.
# TODO Can we use '0>&1 :' somehow instead of 'cat'?
may_fail()
{
  cat < <("${@}");
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
  # We trick bash by making bash consider the 'cat' command to be executed
  # instead.
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
  "${@}" >/dev/null
}

run_silent_stderr()
{
  "${@}" 2>/dev/null
}

run_silent_both()
{
  "${@}" >/dev/null 2>/dev/null
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

  if run_silent_stdout "$@"; then
    return 0;
  fi
  declare ret="$?";
  declare choice="";
  errchoe "${FUNCNAME[0]}: Failed silently: $ret ← $(print_values "$@")";
  read -r -t 10 -n1 -p "Try more verbosely? [y/n] " choice;
  if [[ "$choice" != "y" ]]; then
    return "$ret";
  fi
  "$@";
}
