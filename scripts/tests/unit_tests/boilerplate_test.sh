#!/usr/bin/env false

# version 0.0.0

boilerplate_test() {
  test_ifs
  test_options
  test_paths
  test_runconfig
}

test_ifs() {
  assert_eq "$IFS" $'\n\t' 'We want IFS to be \n\t'
}

test_options() {
  # We cannot test whether all files keep these settings intact. But we can
  # verify that they come out of boilerplate.sh correctly.
  declare opt
  for opt in e u E T; do # -h is not crucial
    assert_match "$-" "*${opt}*" "We need option ${opt}"
  done

  # The shopt -o names we expect
  declare -ar should_have_o=(
    "pipefail"
    "errexit"
    "nounset"
    "errtrace"
    "functrace"
  )
  # The shopt names we expect without -o
  declare -ar should_have=(
    "inherit_errexit"
    "extglob"
    "shift_verbose"
  )

  for opt in "${should_have_o[@]}"; do
    assert_match "$(shopt -po -- "$opt")" "set -o $opt" "Require set -o $opt"
  done
  for opt in "${should_have[@]}"; do
    assert_match "$(shopt -p -- "$opt")" "shopt -s $opt" "Require shopt -s $opt"
  done
}

test_runconfig() {
  assert_set '_run_config["error_frames"]' "Must provide runscript config dictionary"
  assert_set '_run_config["error_skipnoise"]' "Must provide runscript config dictionary"
  assert_set '_run_config["log_loads"]' "Runscript config dictionary must contain default "
  assert_set '_run_config["versioning"]' "Must provide runscript config dictionary"
}

test_paths() {
  assert_match "${caller_path}" "/*" "Caller path must be full path"
  assert_match "${parent_path}" "/*" "Caller path must be full path"
  assert_match "${parent_path}" "/home/+([[:word:]])/dotfiles?(/*)" "We expect testing to be run from ~/dotfiles. May be ok to fail when using differently."
  show_variable _run_config
  assert_set 'predefined_commands' "Boilerplate must set predefined commands"
  declare script_dirname
  script_dirname="$(dirname "$0")"
  assert_eq "$(is_same_location "${parent_path}" "$caller_path/$script_dirname")" "true" "Parent path must be correct"
  assert_eq "$(is_same_location "${parent_path}/run.sh" "$caller_path/$0")" "true" "Scripts must be called run.sh"

  assert_set 'this_location' "Boilerplate must set this_location, even if empty"
  if [[ -n "${this_location}" ]]; then
    assert_eq "${this_location:?Should never trigger}" "$parent_path" "this_location must be honored"
  fi
}
