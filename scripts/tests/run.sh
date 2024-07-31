#!/usr/bin/env bash
# ╭──────────────────────╮
# │ 🅅 ersion             │
# ╰──────────────────────╯
# version 0.0.0
# shellcheck disable=2120
# ╭──────────────────────╮
# │ 🛈 Info               │
# ╰──────────────────────╯
# Starting point for dotfiles tests.
# Here, we implement that starting point of tests, determining WHICH tests are
# run. We do not implement any actual test functions in this file. The
# implementations are sourced via ./commands_test.sh.
# ╭──────────────────────╮
# │ ⚙ Boilerplate        │
# ╰──────────────────────╯
declare -gr dotfiles="${DOTFILES:-"$HOME/dotfiles"}"; # TOKEN_DOTFILES_GLOBAL
declare -gA _sourced_files=( ["runscript"]="" );
declare -gr this_location="";
source "$dotfiles/scripts/boilerplate.sh" "${BASH_SOURCE}" "$@";
satisfy_version "$dotfiles/scripts/boilerplate.sh" 0.0.0;

# ╭──────────────────────╮
# │ 🛠Configuration      │
# ╰──────────────────────╯
_run_config["versioning"]=0;
#_run_config["log_loads"]=1;
_run_config["error_frames"]=2;
# ╭──────────────────────╮
# │ 🗀 Dependencies       │
# ╰──────────────────────╯
load_version "$dotfiles/scripts/version.sh" "0.0.0";
load_version "$dotfiles/scripts/utils.sh" 0.0.0;
load_version "$dotfiles/scripts/userinteracts.sh" "0.0.0";
load_version "commands_test.sh" 0.0.0; # TODO Rename to test_functions.sh
# ╭──────────────────────╮
# │ ⌨  Commands          │
# ╰──────────────────────╯

# Defines 1 top level test for each module. Adds all relevant includes and
# commands.
#source commands_test.sh

# Default command (when no arguments are given)
command_default()
{
  set_args "--help" "$@";
  eval "$get_args";

  subcommand test --raw -- test_boilerplate;
  echo
  subcommand test -- test_boilerplate;
}

command_test()
{
  set_args "--help --raw --" "$@";
  eval "$get_args";

  show_variable argv;

  if (( ${#argv[@]} == 0 )); then
    time subcommand run_all_tests;
    echos "(manual) colour_test";
    echos "(manual) shell_check";
    return;
  fi

  echol "Going to test: $(print_array argv)";
  declare arg;
  for arg in "${argv[@]}"; do
    if [[ "$raw" == "true" ]]; then
      "$arg";
    else
      execute_test "$arg";
    fi
  done
}

# TODO Rename to functional tests
command_run_all_tests()
{
  if [[ ! -v _run_config["declare_optionals"] ]]; then
    abort "$FUNCNAME: expected _run_config to be set";
  fi
  if [[ "$-" != *e* ]]; then
    abort "$FUNCNAME: Must be run in 'set -e' mode";
  fi
  if [[ "$-" != *u* ]]; then
    abort "$FUNCNAME: Must be run in 'set -u' mode";
  fi
  if ! shopt -qp inherit_errexit; then
    abort "$FUNCNAME: Must be run in 'shopt -s inherit_errexit' mode";
  fi
  shopt -p inherit_errexit;

  echou "Tests should take 3 seconds user time";
  execute_test test_bash_meta;
  execute_test test_userinteractions;
  execute_test test_init_standalone;
  execute_test test_version;
  execute_test deploy_test;
  execute_test runscript_init_test;
  execute_test test_setargs_all;
  execute_test test_may_fail;
  execute_test test_boilerplate;
  execute_test test_environment;
  execute_test test_import;
  # TODO
  # #subcommand rundir ../install/ help; # Verify versions at least
}

# ┌────────────────────────┐
# │ Helpers                │
# └────────────────────────┘

execute_test()
{
  # TODO It might be better to just store the outputs and display them on error.
  declare verbose_ok;
  may_fail verbose_ok -- run_verbosity_ladder "$@";
  if [[ "$verbose_ok" == "0" ]]; then
    echok "$(print_values "${text_bg}✔ ${text_normal}" "$@")";
  else
    errchoe "$(print_values "$text_br🚫 ${text_normal}" "$@")";
  fi
}

# ┌────────────────────────┐
# │ Help strings           │
# └────────────────────────┘

declare -r default_help_string='Ad-hoc implementation
DESCRIPTION
  Set ad-hoc during dev to to whatever is needed currently.
  For a generic test starter, use the "test" command.';
declare -r test_help_string='Run tests
SYNOPSIS
  test -- [NAMES...]
DESCRIPTION
  Run the specified tests. When no tests are specified, a predefined subset of
  fire-and-forget tests is executed.

  The provided tests are executed by the "execute_test" helper. When a test
  passes its output is suppresed. Else it is re-run with output.
NAMES
  Test names are the names of bash functions in ./commands_test.sh
OPTIONS
  --raw: Run the test functions specified by NAMES directly, without the
         execute_test wrapper. This will produce errors if the test fails, but
         has no special functionality. For dev and testing.';


# ┌────────────────────────┐
# │ Delegate               │
# └────────────────────────┘
subcommand "${@}";
