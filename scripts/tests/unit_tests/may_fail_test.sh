#!/usr/bin/env bash

# version 0.0.0

# shellcheck disable=SC2030,SC2031

# may_fail() test functions for commands_test.sh.
# Source the tested may_fail function where you are sourcing this.

# Init not to 0 or 1 to avoid confusion
declare -g _may_fail_test_skipper=42

# TODO Put test functions into subshells at a higher level. So we can remove one
#      level of subshelling in the tests.

_may_fail_dummy() {
  # Simulate functions that can fail or succeed.
  # $1 used as return value. Defauts to 0.
  declare -i result
  result="${1:-"0"}"
  return "${result}"
}

may_fail_dummy() {
  # Print something only after running a command which may fail.
  #
  # Use this function to test if may_fail allows skipping with set -e. Setting
  # -e should skip the print command. If this works, this function never prints
  # anything.
  declare -i ret
  ret="${1:?"Missing dummy return value for '${2:-""}' in ${FUNCNAME[1]}"}"
  _may_fail_test_skipper=0
  1>&2 echo "Before potential error"
  _may_fail_dummy "$ret" "${2:-""}" # Returns with code $ret
  1>&2 echo "After potential error ($?) continuing anyway"
  printf -- "%s\n" "${2:-""}"
  _may_fail_test_skipper=1
}

test_may_fail_allow_success() {
  (
    trap - ERR
    set +e
    (
      set -e
      may_fail -- _may_fail_dummy 0 "Allow success"
    )
    re=$?
    set -e
    assert_eq "0" "$re" "${FUNCNAME[0]}: Returning 0 must succeed in may_fail"
  )
}

test_may_fail_allow_failure() {
  (
    trap - ERR
    declare -i re
    set +e
    (
      set -e
      _may_fail_test_skipper=0
      may_fail -- _may_fail_dummy 1 "Allow success"
      _may_fail_test_skipper=1
    )
    re="$?"
    set -e
    assert_eq "0" "$re" "${FUNCNAME[0]}: Returning 1 must succeed in may_fail"
  )
}

test_may_fail_exit() {
  # Same implementation as in test_mayfail_normal_exit(), except here may_fail()
  # is used.
  _may_fail_test_skipper=42
  (
    _may_fail_test_skipper=41
    declare re
    trap - ERR
    (
      _may_fail_test_skipper=20 # A value that is not {0,1}
      declare -r input="Preserve -e"
      declare output="output_variable"
      declare -i retvar=3
      declare ok

      output="$(may_fail retvar -- may_fail_dummy 0 "${input}")"
      assert_eq "$output" "$input" "${FUNCNAME[0]}: normal execution w/o failure"

      output="non_empty"
      output="$(may_fail retvar -- may_fail_dummy 1 "${input}")"
      ok="$?"
      assert_eq "$ok" "0" "assignment leaves set -e intact"
      assert_eq "$output" "" "may_fail should abort before printing"
      assert_eq "$retvar" "3" "may_fail cannot set retvar from subshell"

      retvar=3
      declare -r declared_output="$(may_fail retvar -- may_fail_dummy 1 "${input}")"
      ok="$?"
      assert_eq "$declared_output" "" "declaration leaves set -e intact"
      assert_eq "$retvar" "3" "may_fail cannot set retvar from subshell"
      assert_eq "$ok" "0" "valid construct"

      #      # ❕ Assignments do not survive errors
      #      # ⇒ Assignments are safe in normal code.
      #      retvar=3;
      #      declare declared_output1;
      #      declared_output1="$(may_fail_dummy 1 "${input}")";
      #      ok="$?";
      #      assert_eq "$ok" "0" "${FUNCNAME[0]}: assignment overwrites capture return value";

      # TODO Split the tests into thos for may_fail and thise for declaration
      #      stuff.
      retvar=3
      declare -r declared_output3="$(may_fail_dummy 1 "${input}")"
      ok="$?"
      assert_eq "$ok" "0" "declaration overshadows return value"
      assert_eq "$declared_output3" "" "declaration keeps -e intact"

      # Make sure the start of the output is captured
      declare -r declared_output4="$({
        echo "hi"
        may_fail_dummy 1 "${input}"
      })"
      ok="$?"
      assert_eq "$ok" "0" "declaration overshadows return value"
      assert_eq "${declared_output4}" "hi" "allows earlier output to be assigned"

      assert_eq "20" "$_may_fail_test_skipper" "${FUNCNAME[0]}: may_fail_dummy is in a subshell and cannot set variables"
      _may_fail_test_skipper=21
    )
    re="$?"
    assert_eq "0" "$re" "${FUNCNAME[0]}: may_fail must preserve -e"
    assert_eq "41" "$_may_fail_test_skipper" "${FUNCNAME[0]}: Subshells should preserve variables"
  )

  # Sanity check that the test is implementet correctly
  assert_eq "42" "$_may_fail_test_skipper" "${FUNCNAME[0]}: global variable should not change from subshell"
}

test_may_fail_normal_exit() {
  # Verify that the behaviour WITHOUT may_fail is actually different. And what
  # that behaviour is. Same implementation as in test_may_fail_exit(), except
  # here may_fail() is NOT used.
  # This test implicitly also verifies a may_fail that might surround this test
  # (and if so probably all other tests, too) surrounding.
  _may_fail_test_skipper=42
  (
    _may_fail_test_skipper=41
    declare re
    trap - ERR
    set +e
    (
      set -e
      _may_fail_test_skipper=20 # A value that is not {0,1}
      declare input="Preserve -e"
      declare output
      output="$(may_fail_dummy 1 "${input}")"
      may_fail_dummy 1 "${input}"
      # We WANT to set -e exit out before this line. To identify the expected
      # failure confition, theis would return status 0 if the exiting were
      # erroneously missing.
      return 0 # Unreachable
    )          # Should fail
    re="$?"
    set -e
    assert_eq "1" "$re" "${FUNCNAME[0]}: lacking may_fail should NOT preserve -e"
    assert_eq "41" "$_may_fail_test_skipper" "${FUNCNAME[0]}: Subshells should preserve variables"
  )

  # Sanity check that the test is implementet correctly
  assert_eq "42" "$_may_fail_test_skipper" "${FUNCNAME[0]}: global variable should not change from subshell"
}

test_may_fail_return() {
  (
    trap - ERR
    declare -i ret_holder

    may_fail ret_holder -- _may_fail_dummy 0 "Relay success"
    assert_eq "0" "${ret_holder}" "may_fail must relay (success) return code"

    may_fail ret_holder -- _may_fail_dummy 1 "Relay failure"
    assert_eq "1" "${ret_holder}" "may_fail must relay (failure) return code"

    may_fail ret_holder -- _may_fail_dummy 234 "Relay failure"
    assert_eq "234" "${ret_holder}" "may_fail must relay any return code"
  )
}

test_may_fail_options() {
  (
    trap - ERR
    set -e

    may_fail -- _may_fail_dummy 0 "Options"
    assert_eq "${-//[^e]/}" "e" "may_fail must restore -e"
    may_fail -- _may_fail_dummy 1 "Options"
    assert_eq "${-//[^e]/}" "e" "may_fail must restore -e"

    # At the moment we do not allow unsetting -e before may_fail.
    # set +e;
    # may_fail -- _may_fail_dummy 0 "Options";
    # assert_eq "${-//[^e]/}" "" "may_fail must restore +e";
    # may_fail -- _may_fail_dummy 1 "Options";
    # assert_eq "${-//[^e]/}" "" "may_fail must restore +e";
  )
}

test_may_fail_errexit() {
  (
    declare -i ret
    trap - ERR
    set +e
    (may_fail -- echo "hi")
    ret="$?"
    set -e
    assert_eq "$ret" "1" "may_fail must not allow +e in the caller"
  )
}
