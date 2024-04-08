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
_run_config["versioning"]=1;
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

  if [[ ! -v _run_config["declare_optionals"] ]]; then
    abort "$FUNCNAME: expected _run_config to be set";
  fi
  time subcommand run_all_tests;

  echos "(manual) colour_test";
  echos "(manual) shell_check";
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

  # TODO
  # #subcommand rundir ../install/ help; # Verify versions at least
}

# ┌────────────────────────┐
# │ Helpers                │
# └────────────────────────┘

execute_test()
{
  if run_verbosity_ladder "$@"; then
    echok "$(print_values "${text_bg}✔ ${text_normal}" "$@")";
  else
    errchoe "$(print_values "$text_br)🚫 ${text_normal}" "$@")";
  fi
}

declare -r default_help_string=$'Start a subset of functional tests
Not run:
  - colour_test
  - shell_check
  (- anything that doesnt have a test)';

subcommand "${@}";
