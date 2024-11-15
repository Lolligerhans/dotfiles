#!/usr/bin/env bash

# version 0.0.0

# shellcheck disable=2015,2145

# Ensuring version even if included already
load_version "$dotfiles/scripts/version.sh" 0.0.0;
#load_version "$dotfiles/scripts/assert.sh" 0.0.0;
#load_version "$dotfiles/scripts/boilerplate.sh" 0.0.0;
#load_version "$dotfiles/scripts/cache.sh" 0.0.0;
#load_version "$dotfiles/scripts/error_handling.sh" 0.0.0;
#load_version "$dotfiles/scripts/git_utils.sh" 0.0.0;
#load_version "$dotfiles/scripts/progress_bar.sh" 0.0.0;
#load_version "$dotfiles/scripts/setargs.sh" 0.0.0;
load_version "$dotfiles/scripts/termcap.sh" 0.0.0;
load_version "$dotfiles/scripts/utils.sh" 0.0.0;

declare -r tag="asserts";
if [[ -v _sourced_files["$tag"] ]]; then return 0; fi
_sourced_files["$tag"]="";

# Array asserts could be found here
# https://github.com/torokmark/assert.sh/blob/main/assert.sh

# Test this once. If the user changes if before calling this, their loss.
if [[ "$-" != *e* ]]; then
  abort "$BASH_SOURCE: Insisting on 'set -e'";
fi

# log_assert() {
#   declare -ri ret="${1:?}";
#   declare -r func="${2:-"<func>"}";
#   declare -r file="${3:-"<file>"}";
#   declare -ri line="${4:-"<line>"}";
#   declare -r msg="${@:5}";
#   show_variable "ret";
#   show_variable "func";
#   show_variable "file";
#   show_variable "line";
#   show_variable "msg";
#
#   declare sym;
#   case "$ret" in
#     0) sym="${text_green}✔";;
#     1) sym="${text_red}✖";;
#     *) sym="${text_user}❓"
#   esac
#   echo "${sym} | ${file}:${line} | ${func} |" "$msg${text_normal}";
# }

log_success() { echo "${text_green}✔ | ${BASH_SOURCE[2]}:${BASH_LINENO[1]} | ${FUNCNAME[2]} |" "$@${text_normal}"; }
log_failure() { 1>&2 echo "${text_red}✖ | ${BASH_SOURCE[2]}:${BASH_LINENO[1]} | ${FUNCNAME[2]} |" "$@${text_normal}"; }

assert_set()
{
  declare -r msg="${2-""}";
  if [[ -v "${1:?}" ]]; then
    (( "${#msg}" != 0 )) && log_success "${1@Q} must be set | $msg" || :;
    return 0;
  else
    (( "${#msg}" != 0 )) && log_failure "${1@Q} must be set | $msg" || :;
    return 1;
  fi
}

assert_unset()
{
  declare -r msg="${2-""}";
  if [[ ! -v "${1:?}" ]]; then
    (( "${#msg}" != 0 )) && log_success "${1@Q} is undefined | $msg" || :;
    return 0;
  else
    (( "${#msg}" != 0 )) && log_failure "${1@Q} is undefined | $msg" || :;
    return 1;
  fi
}

assert_eq()
{
  declare -r msg="${3-""}";
  if [[ "$1" == "$2" ]]; then
    (( "${#msg}" != 0 )) && log_success "${1@Q} == ${2@Q} | $msg" || :;
    return 0;
  else
    (( "${#msg}" != 0 )) && log_failure "${1@Q} == ${2@Q} | $msg" || :;
    return 1;
  fi
}

assert_not_eq()
{
  declare -r msg="${3-""}";
  if [[ "$1" != "$2" ]]; then
    (( "${#msg}" != 0 )) && log_success "$1 != $2 | $msg" || :;
    return 0;
  else
    (( "${#msg}" != 0 )) && log_failure "$1 != $2 | $msg" || :;
    return 1;
  fi
}

# Pattern match "$1"== $2. Uses pattern matching with "==", not "=~", no string
# comparison.
# Examples:
#     assert_match "tested__string" "*_*" "Contains an underscore"
#     assert_match "tested__string" "*(!(f))" "Does not contain an f"
assert_match()
{
  declare -r msg="${3-""}";
  # shellcheck disable=2053
  if [[ "$1" == ${2:?Pattern required} ]]; then # Match $2 as pattern
    (( "${#msg}" != 0 )) && log_success "'$1' == pattern{$2} | $msg" || :;
    return 0;
  else
    (( "${#msg}" != 0 )) && log_failure "'$1' == pattern{$2} | $msg" || :;
    return 1;
  fi
}

# $1: Expected return value
# ${@:2}: Command that must return $1
# Hides some of the outputs.
assert_returns()
{
  declare -ri expected="${1:?}";
  shift;

  # When expecting failure, hide stderr.
  # When expecting success, hide stdout.
  declare -i ret;
  may_fail ret -- run_silent $(( expected == 0 ? 1 : 2 )) "${@:?}";

  if (( ret == expected )); then
    log_success "\$? == ${expected} | ${@}" || true;
  else
    log_failure "\$? == ${expected} | ${@}" || true;
  fi
}
