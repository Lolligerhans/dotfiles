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
declare -r tag="bash_meta"
if [[ -v _sourced_files["$tag"] ]]; then return 0; fi
_sourced_files["$tag"]=""
# ╭──────────────────────╮
# │ 🗀 Dependencies       │
# ╰──────────────────────╯
load_version "$dotfiles/scripts/version.sh" "0.0.0"
#load_version "$dotfiles/scripts/setargs.sh"
#load_version "$dotfiles/scripts/termcap.sh"
load_version "$dotfiles/scripts/userinteracts.sh" "0.0.0"
load_version "$dotfiles/scripts/utils.sh" "0.0.0"
# ╭──────────────────────╮
# │ 🖩 Utils              │
# ╰──────────────────────╯
# ╭──────────────────────╮
# │ 𝑓 Functional         │
# ╰──────────────────────╯

bash_caller() {
  errchof "I think its not working yet"
  abort "Not implemented yet"
  echoi "${@@A}"
  declare -i index="$1"
  while ((index > 0)); do
    caller "$i"
    ((index--))
  done
}

# This function executes "$@" IN A SUBSHELL, allowing failure, but keeping set
# -e intact. The first error of "$@" will "abort" execution, with may_fail()
# returning 0.
# Synopsis:
#     may_fail -- command [arg1] [arg2]
#     may_fail return_var -- command [arg1] [arg2]
may_fail() {
  # Contrary to popular demand, Bash's set -e, set -u and pipefail can be
  # permanently disabled by if, ||, &&, while, until, !, recursively with
  # disregard of the actual flag:
  #
  #     set -euETo pipefail; # nice try!
  #     shopt -s inherit_errexit
  #     cd /
  #     install_program()
  #     {
  #       mkdir a || true
  #       set -e; ❔
  #       cd /temp; # ❕ typo, no cd happens. set -e is ignored within ||
  #       rm -rf *; # ⚠️
  #       wget https://setup.sh | sh; # Too late, / already removed.
  #     }
  #     install_program || true; # ❌ bad
  #
  # We disable set -e surrounding a subshell. Unfortunately this prevents
  # interaction with the parent process.
  #
  # An alternative would be to use:
  #     declare dummy="$( "$@" )"
  # That way the return value is lost, but we must not worry about any flags:
  # The declaration counts as last command (so this line returns 0 regardless
  # failures of $@). However, we might not like storing stdout in a variable and
  # we may need a return value.
  if (($# < 2)); then
    abort "Expected at least 2 arguments"
  fi
  declare ret_name
  if [[ "$1" == "--" ]]; then
    ret_name=""
    shift
  else
    ret_name="$1"
    if [[ "$2" != "--" ]]; then
      abort "Expected '--' as second argument"
    fi
    shift 2
  fi
  if [[ "$-" != *e* ]]; then
    abort "Expected 'set -e'"
  fi
  # errchol "☐ $(print_values "${FUNCNAME[0]}" "$@")"
  declare -i _mf_result_834u92834 # Avoid name collisions

  # Disable errexit and ERR trap before execution and re-enable afterwards
  declare err_trap
  err_trap="$(trap -p ERR)"
  declare -r flags="$-"
  trap - ERR
  set +e
  (
    eval "$err_trap"
    set -e
    "$@"
  )
  _mf_result_834u92834="$?"
  if [[ "$flags" == *e* ]]; then
    set -e
  fi
  eval "$err_trap"

  # if (( _mf_result_834u92834 == 0 )); then
  #   errchol "☑ $(print_values "${FUNCNAME[0]}" "$@")"
  # else
  #   errchol "☒ $(print_values "${FUNCNAME[0]}" "$@")"
  # fi
  if [[ -n "$ret_name" ]]; then
    declare -n -- _mf_ret_777734234="${ret_name}"
    _mf_ret_777734234="$_mf_result_834u92834"
  fi
  return 0
}

# Run $@ hiding
#   - ${1} == 0: nothing
#   - ${1} == 1: file descriptor 1
#   - ${1} == 2: file descriptor 2
#   - ${1} == 3: file descriptor 1 and 2
run_silent() {
  declare silenter
  case "$1" in
  0) silenter="" ;;
  1) silenter="run_silent_stdout" ;;
  2) silenter="run_silent_stderr" ;;
  3) silenter="run_silent_both" ;;
  *)
    errchoe "${FUNCNAME[0]}: param 1 must be 1, 2 or 3"
    return 1
    ;;
  esac
  ${silenter} "${@:2}"
  return "$?"
}

run_silent_stdout() {
  "${@}" >/dev/null
}

run_silent_stderr() {
  "${@}" 2>/dev/null
}

run_silent_both() {
  "${@}" >&/dev/null
}

# Pritns assignments of variables in an unambiguous way. For testing.
#
# $1: name of a variable
# $n (optional): more names of variables
show_variable() {
  declare unique_name_1987341937
  for unique_name_1987341937 in "$@"; do
    # Helper to print content of a single variable
    _show_variable_implementation "$unique_name_1987341937"
  done
}

_show_variable_implementation() {
  declare -n _ref_sv_348u928374="${1:?Missing variable name}"
  (($# == 1)) || return # Sanity check: Do not attempt to pass more arguments
  # We use the dictionary notation array_name[@]. In Bash, all variables are
  # implicitly dictionaries. Arrays are just dictionaries using keys "0", "1",
  # and so on. Strings are just dictionaries using key "0" exclusively.
  echoi "${_ref_sv_348u928374[@]@A}"
}

# $1: one SIGNAL. See tap -l.
# $2: New trap handler to prepend. Not ending with semicolon
#
#     trap 'echo ohnoes' ERR
#     trap_prepend ERR "echo second nose"
trap_prepend() {
  declare -r signal="${1:?Missing signal}" # ERR or EXIT or INT or ...
  declare current_trap=""
  current_trap="$(trap -p -- "${signal}")"
  # Start format:
  #     trap -- 'quoted '\''string' ERR
  current_trap="${current_trap#"trap -- "}"
  current_trap="${current_trap%" $signal"}"
  # Here this format:
  #     'quoted '\''string'

  # Unwrap the quoting layer used by bash. Presumably bash guarantees it to be
  # suitable as input.
  eval "current_trap=$current_trap"
  # Here this format:
  #     quoted 'string
  new_trap="${2:?Missing command}; ${current_trap}"

  trap -- "$new_trap" "$signal"
}
