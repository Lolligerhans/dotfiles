#!/usr/bin/env false

# version 0.0.0

# This file is sourced by commands_test.sh.
#
# Here we define test functions for bash_meta.sh that cannot be squeezed into
# the commands_test.sh.

bash_meta_test() {
  test_silencing
  test_bash_at_AQ
}

test_silencing() {
  declare out=""
  out="$(run_silent 1 'echo' 'hello silence')"
  assert_eq "$out" "" "No stdout when silenced"

  # shellcheck disable=SC2317
  _ctbm_out_err() { 1>&2 echo "hello silence"; }
  out=""
  out="$(2>&1 run_silent 1 '_ctbm_out_err')"
  assert_eq "$out" "hello silence" "Allowing stderr despite silence"
  unset _ctbm_out_err

  out=""
  # shellcheck disable=SC2116
  out="$(echo "still working")"
  assert_eq "$out" "still working" "fd unchanged"
  # shellcheck disable=SC2116
  out="$(2>&1 echo "hello silence")"
  assert_eq "$out" "hello silence" "fd unchanged"
}

test_bash_at_AQ() {
  declare -r constant="const"
  declare -a array=(1 2)
  declare -A map=(["a"]="b")
  declare -Ar solutions=(
    ["constant"]="declare -r constant='const'"
    ["array"]='declare -a array=([0]="1" [1]="2")'
    ["map"]='declare -A map=([a]="b" )'
    [quote]="\'"          # @Q quotes a single quote as 0x5c27
    [double_quote]=\'\"\' # @Q quotes a double quote as 0x272227
  )
  declare -ar names=(constant arr map)

  assert_eq "${constant[@]@A}" "${solutions["constant"]}" "@A must generate constants"
  assert_eq "${array[@]@A}" "${solutions["array"]}" "@A must generate arrays"
  assert_eq "${map[@]@A}" "${solutions["map"]}" "@A must generate maps"

  declare -r quote=\'
  declare -r double_quote=\"
  declare -r slash="'"
  assert_eq "${quote[@]@Q}" "${solutions["quote"]}" "@Q must quote single quotes"
  assert_eq "${double_quote[@]@Q}" "${solutions["double_quote"]}" "@Q must quote double quotes"
}
