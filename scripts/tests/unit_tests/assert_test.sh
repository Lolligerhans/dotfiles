#!/usr/bin/env false

# version 0.0.0

# shellcheck disable=SC2015
assert_test() {

  declare _assert_test_is_set="set"
  declare _assert_test_is_not_set

  assert_set "_assert_test_is_set" "set mut identify set" || return 1
  assert_set "_assert_test_is_not_set" "set mut identify set" && return 1 || true

  assert_unset "_assert_test_is_set" "set mut identify set" && return 1 || true
  assert_unset "_assert_test_is_not_set" "set mut identify set" || return 1

  assert_eq "a" "a" "compare strings" || return 1
  assert_eq "a" "A" "Case sensitive" && return 1 || true
  assert_eq "a" "*a*" "Patterns not allowed" && return 1 || true
  assert_eq "*a*" "a" "Patterns not allowed" && return 1 || true
  assert_eq "" "" "Empty strings are equal" || return 1

  assert_not_eq "a" "a" "compare strings" && return 1 || true
  assert_not_eq "a" "A" "Case sensitive" || return 1
  assert_not_eq "a" "*a*" "Patterns not allowed" || return 1
  assert_not_eq "*a*" "a" "Patterns not allowed" || return 1
  assert_not_eq "" "" "Empty strings are equal" && return 1 || true

  assert_match "a" "a" "compare strings" || return 1
  assert_match "a" "A" "Case sensitive" && return 1 || true
  assert_match "a" "*a*" "Patterns allowed" || return 1
  assert_match "*a*" "a" "Patterns not allowed on left side" && return 1 || true
  (assert_match "" "" "Empty pattern is malformed") && return 1 || true

}
