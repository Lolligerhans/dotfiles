#!/usr/bin/env false

# version 0.0.0

utils_test() {
  test_abort
  test_bash_source_foreign_idx
  test_common_prefix
  test_compare_string_lte_version
  test_date_nocolon
  test_repeat_string
  test_remove_ansi_escapes
}

test_abort_helper() {
  printf -- "a"
  abort "This always aborts"
  printf -- "z"
  return 0
}

test_abort() {
  assert_returns 1 abort "Abort returns 1"
  assert_returns 1 test_abort_helper "Functions calling abort return 1"
  declare output abort_ret=4
  output="$(may_fail -- test_abort_helper)"
  assert_eq "$output" "a" "Functions should not continue after aborting"
}

test_bash_source_foreign_idx() {
  declare -i res
  bash_source_foreign_idx res

  assert_eq "$res" "2" "2 hops out of this file (here -> utils_test() -> out)"
}

test_compare_string_lte_version() {
  declare -r small="1.9.9"
  declare -r middle="1.9.10"
  declare -r large="1.10"

  assert_eq "$(compare_string_lte_version "$small" "$small")" "true" "Small is less or equal to small"
  assert_eq "$(compare_string_lte_version "$small" "$middle")" "true" "Small is less or equal to middle"
  assert_eq "$(compare_string_lte_version "$small" "$large")" "true" "Small is less or equal to large"
  assert_eq "$(compare_string_lte_version "$middle" "$small")" "false" "Middle is greater than small"
  assert_eq "$(compare_string_lte_version "$middle" "$middle")" "true" "Middle is less or equal to middle"
  assert_eq "$(compare_string_lte_version "$middle" "$large")" "true" "Middle is less or equal to large"
  assert_eq "$(compare_string_lte_version "$large" "$small")" "false" "Large is greater than small"
  assert_eq "$(compare_string_lte_version "$large" "$middle")" "false" "Large is greater than middle"
  assert_eq "$(compare_string_lte_version "$large" "$large")" "true" "Large is less or equal to large"
}

test_date_nocolon() {
  declare -r pattern='+([[:digit:]T+-])'
  declare str
  str="$(date_nocolon)"
  declare -r example="2024-12-31T23-59-59+11-59"
  assert_match "$str" "$pattern" "Should produce date/times without colons"
  assert_eq "${#str}" "${#example}" "Should be same length as example"
}
