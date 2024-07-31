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

log_success() { echo "${text_green}✔ | ${BASH_SOURCE[2]}:${BASH_LINENO[1]} | ${FUNCNAME[2]} |" "$@${text_normal}"; }
log_failure() { 1>&2 echo "${text_red}✖ | ${BASH_SOURCE[2]}:${BASH_LINENO[1]} | ${FUNCNAME[2]} |" "$@" "${text_normal}"; }

assert_unset()
{
  declare -r msg="${2-""}"
  if [[ ! -v "$1" ]]; then
    (( "${#msg}" != 0 )) && log_success "$1 is undefined | $msg" || :;
    return 0
  else
    (( "${#msg}" != 0 )) && log_failure "$1 is undefined | $msg" || :;
    return 1
  fi
}
assert_eq()
{
  declare -r msg="${3-""}"
  if [[ "$1" == "$2" ]]; then
    (( "${#msg}" != 0 )) && log_success "'$1' == '$2' | $msg" || :;
    return 0
  else
    (( "${#msg}" != 0 )) && log_failure "'$1' == '$2' | $msg" || :;
    return 1
  fi
}
assert_not_eq()
{
  declare -r msg="${3-""}"
  if [[ "$1" != "$2" ]]; then
    (( "${#msg}" != 0 )) && log_success "$1 != $2 | $msg" || :;
    return 0
  else
    (( "${#msg}" != 0 )) && log_failure "$1 != $2 | $msg" || :;
    return 1
  fi
}
assert_match()
{
  declare -r msg="${3-""}"
  if [[ "$1" == $2 ]]; then # Match $2 as pattern
    (( "${#msg}" != 0 )) && log_success "'$1' == pattern{'$2'} | $msg" || :;
    return 0
  else
    (( "${#msg}" != 0 )) && log_failure "'$1' == pattern{'$2'} | $msg" || :;
    return 1
  fi
}
