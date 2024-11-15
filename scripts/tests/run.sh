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
# implementations are sourced via ./tests.sh.
# ╭──────────────────────╮
# │ ⚙ Boilerplate        │
# ╰──────────────────────╯
declare -gr dotfiles="${DOTFILES:-"$HOME/dotfiles"}" # TOKEN_DOTFILES_GLOBAL
declare -gA _sourced_files=(["runscript"]="")
declare -gr this_location=""
source "$dotfiles/scripts/boilerplate.sh" "${BASH_SOURCE[0]}" "$@"
satisfy_version "$dotfiles/scripts/boilerplate.sh" 0.0.0

# ╭──────────────────────╮
# │ 🛠Configuration      │
# ╰──────────────────────╯

_run_config["versioning"]=1
_run_config["log_loads"]=1
# Prevent lengthy error trace in logs
_run_config["error_frames"]=2

# ╭──────────────────────╮
# │ 🗀 Dependencies       │
# ╰──────────────────────╯
load_version "$dotfiles/scripts/version.sh" "0.0.0"
load_version "$dotfiles/scripts/utils.sh" 0.0.0
load_version "$dotfiles/scripts/userinteracts.sh" "0.0.0"
# Defines 1 top level test for each module. Adds all relevant includes and
# commands.
load_version "$parent_path/tests.sh" 0.0.0 # TODO Rename to test_functions.sh

# ╭──────────────────────╮
# │ 🗺 Globals           │
# ╰──────────────────────╯

declare -r log_dir="log/"
1>&2 ensure_directory "$log_dir"
# Location for the current execution. Copied to a permanent location at the end.
declare -r logfile="${log_dir}/test.log"
: >"${logfile}" # Clear file

declare -r dotfiles_test_dir="/tmp/test_dotfiles/"

# ╭──────────────────────╮
# │ ⌨  Commands          │
# ╰──────────────────────╯

# Default command (when no arguments are given)
command_default() {
  set_args "--help" "$@"
  eval "$get_args"

  string_test
  return
  subcommand test --automated

  # test_string_to_array
  # utils_test
  # fileinteracts_test
  # subcommand test --fail
  # test_bash_at_AQ
  # boilerplate_test
}

command_delete_logs() {
  set_args "--help" "$@"
  eval "$get_args"

  rm -v "${log_dir:?}/"*
}

command_test() {
  set_args "--help --all --automated --colour --fail --shellcheck --" "$@"
  eval "$get_args"

  declare -Ar test_functions=(
    ["automated"]="automated_tests"
    ["colour"]="colour_test"
    ["fail"]="fail_test"
    ["shellcheck"]="shell_check_test"
  )

  declare arg="" func=""
  for arg in "${!test_functions[@]}"; do
    # Reference the variable created by setargs
    declare -n _arg="$arg"
    if [[ "$all" == "true" && "$arg" != "fail" ]] || [[ "$_arg" == "true" ]]; then
      echo
      echoL "${arg}..."
      echo
      func="${test_functions[$arg]}"
      "$func" "${argv[@]}"
    fi
  done
  save_log_file
}

# ╭──────────────────────╮
# │ 𝑓 Test groups        │
# ╰──────────────────────╯

# Here we bundle tests so we do not have to spam the 'test' subcommand when
# tests can/should be run together.

# Fully automated tests
automated_tests() {
  set_args "--" -- "$@"
  eval "$get_args"

  if [[ ! -v _run_config["declare_optionals"] ]]; then
    abort "${FUNCNAME[0]}: expected _run_config to be set"
  fi

  declare t
  for t in "${auto_test_list[@]}"; do
    execute_test "${argv[@]}" -- "${t}"
  done
  # TODO
  # #subcommand rundir ../install/ help; # Verify versions at least
}

# ╭──────────────────────╮
# │ 🖩 Utils              │
# ╰──────────────────────╯

# Runs an individual test function that returns 0 on success, and fails on
# error.
execute_test() {
  set_args "--show --" "$@"
  eval "$get_args"

  declare -i silent_ret=-1
  may_fail silent_ret -- run_silent 3 "${argv[@]}"

  declare symbol="${text_br}⛔"
  declare echoer="echoe"
  if ((silent_ret == 0)); then
    symbol="${text_bg}✅"
    echoer="echok"
  fi
  "${echoer}" "$(print_values "${symbol} ${argv[0]} ${text_normal}" "${argv[@]:1}")" |
    tee -a "${logfile}"
  if ((silent_ret == 0)); then
    return
  fi
  if [[ "$show" == "true" ]]; then
    { 2>&1 may_fail -- "${argv[@]}"; } | tee -a "${logfile}"
  else
    { 2>&1 may_fail -- "${argv[@]}"; } &>>"${logfile}"
  fi
}

# ╭──────────────────────╮
# │ 𝑓 Functional         │
# ╰──────────────────────╯

save_log_file() {
  # Copy the log file to a permanent location
  declare logfile_permanent
  logfile_permanent="$log_dir/$(date_nocolon).log"
  declare -r logfile_permanent
  1>&2 show_variable logfile_permanent
  command xclip -i <<<"$logfile_permanent" || true
  1>&2 ensure_directory "$log_dir"
  1>&2 cp "${logfile}" "$logfile_permanent" || true
}

# ╭──────────────────────╮
# │ 🖹 Help strings       │
# ╰──────────────────────╯

declare -r clear_help_string="Delete all log files
DESCRIPTION
  Deletes all files in '$log_dir/'"

declare -r default_help_string='Ad-hoc implementation
DESCRIPTION
  Set ad-hoc during dev to to whatever is needed currently.
  For a generic test starter, use the "test" command.'

declare -r test_help_string='Run tests
SYNOPSIS
  test --group
  test --group -- arg
  test [--groups...] -- [args...]
DESCRIPTION
  Run the specified tests. Each --group bundles one or more of the test
  functions defined in ./tests.sh.

  When values are provided for argv, they are passed to all executed tests.
  Typically you would run only one test with this option.
EXAMPLE
  # Runs automated hiding errors
  test --automated
  # Runs automated tests, printing errors to screen
  test --automated -- --show
OPTIONS (--groups)
  --all: Run all available tests
  --automated: Runs fully automated tests. Writes logfile for failed tests.
  --colour: Test the availability of terminal colours. A human must interpret
    the output.
  --fail: Run a test that fails on purpose.
  --shellcheck: Runs shellcheck on dotfiles'

# ╭──────────────────────╮
# │ ⚙ Boilerplate        │
# ╰──────────────────────╯

subcommand "${@}"
