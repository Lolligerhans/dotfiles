#!/usr/bin/env bash

# version 0.0.0

test_setargs() {
  if [[ ! -v _run_config["declare_optionals"] ]]; then
    abort "${FUNCNAME[0]}: expected _run_config[\"declare_optionals\"] to be set"
  fi
  # We wrote most tests when the declare_optionals config didnt exist.
  # Temporarily disable the feature.
  declare -r old_optionals="${_run_config["declare_optionals"]}"
  _run_config["declare_optionals"]=0

  # ❗ Increase when adding new tests
  # TODO: Determine automatically
  declare -i max=28
  declare -i t
  declare f

  # Go backwards so we can more easily test the newest test when adding some
  for ((t = max; t >= 1; --t)); do
    f="test_setargs_${t}"
    "$f"
  done
  _run_config["declare_optionals"]="$old_optionals"

  echok "${FUNCNAME[0]}"
}

test_setargs_1() {
  >/dev/null assert_eq "${_run_config["declare_optionals"]}" "0" "${FUNCNAME[0]}: This function runs in old mode"
  set_args "--r=" "--r=r_val"
  eval "$get_args"
  >/dev/null assert_eq "$r" "r_val" "${FUNCNAME[0]}: Required value must be set"
}

test_setargs_2() {
  set_args "--d=d"
  eval "$get_args"
  >/dev/null assert_eq "$d" "d" "${FUNCNAME[0]}: Default value must be set"
}

test_setargs_3() {
  set_args "--d=d" --d=changed
  eval "$get_args"
  >/dev/null assert_eq "$d" "changed" "${FUNCNAME[0]}: Default value must be changed"
}

test_setargs_4() {
  set_args "--r=" "required"
  eval "$get_args"
  >/dev/null assert_eq "$r" "required" "${FUNCNAME[0]}: Required parameter must be set positionally"
}

test_setargs_5() {
  set_args "--d=d" "non-default"
  eval "$get_args"
  >/dev/null assert_eq "$d" "non-default" "${FUNCNAME[0]}: Default parameter must be set positionally"
}

test_setargs_6() {
  set_args "--f" "--f"
  eval "$get_args"
  >/dev/null assert_eq "$f" "true" "${FUNCNAME[0]}: Flag must be set"
}

test_setargs_7() {
  set_args "--f --d=d" "alternative"
  eval "$get_args"
  >/dev/null assert_eq "$f" "false" "${FUNCNAME[0]}: Flag must not be set"
  >/dev/null assert_eq "$d" "alternative" "${FUNCNAME[0]}: Default parameter must be set positionally"
}

test_setargs_8() {
  set_args "--f --d=d --d2=d2" "alternative"
  eval "$get_args"
  >/dev/null assert_eq "$f" "false" "${FUNCNAME[0]}: Flag must not be set"
  >/dev/null assert_eq "$d" "alternative" "${FUNCNAME[0]}: Default parameter must be set positionally"
  >/dev/null assert_eq "$d2" "d2" "${FUNCNAME[0]}: Default parameter 2 must be defaulted"
}

test_setargs_9() {
  set_args "--f --r= --d=d --d2=d2" "alternative"
  eval "$get_args"
  >/dev/null assert_eq "$f" "false" "${FUNCNAME[0]}: Flag must not be set"
  >/dev/null assert_eq "$r" "alternative" "${FUNCNAME[0]}: First param gets the data"
  >/dev/null assert_eq "$d" "d" "${FUNCNAME[0]}: Default parameter must be defaulted"
  >/dev/null assert_eq "$d2" "d2" "${FUNCNAME[0]}: Default parameter 2 must be defaulted"
}

test_setargs_10() {
  set_args "--f --r= -r2= -f2 --d=d --d2=d2" "dat1" "dat2" "-f2" "-r2=r2"
  eval "$get_args"
  >/dev/null assert_eq "$f" "false" "${FUNCNAME[0]}: Flag must not be set"
  >/dev/null assert_eq "$r" "dat1" "${FUNCNAME[0]}: Required 1 set by data1"
  >/dev/null assert_eq "$r2" "r2" "${FUNCNAME[0]}: Required 2 explcitly"
  >/dev/null assert_eq "$f2" "true" "${FUNCNAME[0]}: Flag 2 must be set"
  >/dev/null assert_eq "$d" "dat2" "${FUNCNAME[0]}: Default parameter 1 is fed data2"
  >/dev/null assert_eq "$d2" "d2" "${FUNCNAME[0]}: Default parameter 2 must be defaulted"
}

test_setargs_11() {
  set_args "--r=" "--r" "req"
  eval "$get_args"
  >/dev/null assert_eq "$r" "req" "${FUNCNAME[0]}: Required parameter gets split data"
}

test_setargs_12() {
  set_args "-d=d --r=" "--r" "req"
  eval "$get_args"
  >/dev/null assert_eq "$d" "d" "${FUNCNAME[0]}: Default parameter has default value"
  >/dev/null assert_eq "$r" "req" "${FUNCNAME[0]}: Required parameter gets split data"
}

# Differentiate between positional and split argument data, when order differs
test_setargs_13() {
  set_args "--r= -r2= -d=d" "positional" "--r" "split"
  eval "$get_args"
  >/dev/null assert_eq "$r" "split" "${FUNCNAME[0]}: Required parameter gets explicit split data"
  >/dev/null assert_eq "$r2" "positional" "${FUNCNAME[0]}: Required parameter 2 gets data argument"
  >/dev/null assert_eq "$d" "d" "${FUNCNAME[0]}: Default parameter has default value"
}

# Just a wild test without pattern
test_setargs_14() {
  set_args "-r1= -f1 -d1=d1 --r2= --f2 --d2=d2 -r3= -f3 -d3=d3" \
    "--d2=d 2" --r2 "r 2" -f3 r_1 -r3=-r_3 d_1 -f1
  eval "$get_args"
  >/dev/null assert_eq "$r1" r_1 "${FUNCNAME[0]}: Required 1 is set positionally"
  >/dev/null assert_eq "$f1" "true" "${FUNCNAME[0]}: Flag 1 is set"
  >/dev/null assert_eq "$d1" d_1 "${FUNCNAME[0]}: Default 1 is set positionally"
  >/dev/null assert_eq "$r2" "r 2" "${FUNCNAME[0]}: Required 2 is set by split data"
  >/dev/null assert_eq "$f2" "false" "${FUNCNAME[0]}: Flag 2 is default"
  >/dev/null assert_eq "$d2" "d 2" "${FUNCNAME[0]}: Default 1 is set explicitly"
  >/dev/null assert_eq "$r3" -r_3 "${FUNCNAME[0]}: Required 3 is set directly"
  >/dev/null assert_eq "$f3" "true" "${FUNCNAME[0]}: Flag 3 is set"
  >/dev/null assert_eq "$d3" "d3" "${FUNCNAME[0]}: Default 3 is left at default value"
}

# Typical use case:
#  - Required parameters first
#  - Positional arguments first
test_setargs_15() {
  set_args "-r1= -r2= -r3= -d1=d1 -d2=d2 -d3=d3 --f1 --f2" \
    -d3 d_3 --f1=test "r_1" -r3 r_3 -d2=d_2 "r_2"
  eval "$get_args"
  >/dev/null assert_eq "$r1" r_1 "${FUNCNAME[0]}: Required 1 is set positionally"
  >/dev/null assert_eq "$r2" r_2 "${FUNCNAME[0]}: Required 2 is set positionally"
  >/dev/null assert_eq "$r3" r_3 "${FUNCNAME[0]}: Required 2 is set by split data"
  >/dev/null assert_eq "$d1" d1 "${FUNCNAME[0]}: Default 1 is set to default"
  >/dev/null assert_eq "$d2" d_2 "${FUNCNAME[0]}: Default 2 is set explicitly"
  >/dev/null assert_eq "$d3" d_3 "${FUNCNAME[0]}: Default 3 is set by split data"
  >/dev/null assert_eq "$f1" "test" "${FUNCNAME[0]}: Flag 1 is set"
  >/dev/null assert_eq "$f2" "false" "${FUNCNAME[0]}: Flag 2 is not set"
}

# Missing force argument
test_setargs_16() {
  # Some boilerplate for negative tests:
  (
    trap - ERR
    set +e
    (
      &>/dev/null set_args "-r1="
    )
    re=$?
    set -e
    >/dev/null assert_not_eq "0" "$re" "${FUNCNAME[0]}: Test should generate error"
    >/dev/null assert_unset "_r1" "${FUNCNAME[0]}: Invalid parameter should remain unset"
  )
}

# Too many positional args
test_setargs_17() {
  (
    trap - ERR
    set +e
    (&>/dev/null set_args "-r1=" "dat1" dat2)
    re=$?
    set -e
    >/dev/null assert_not_eq "0" "$re" "${FUNCNAME[0]}: Test should generate error"
  )
}

# Double dash to force positional data
test_setargs_18() {
  set_args "--f -r=" "--" "--f"
  eval "$get_args"
  >/dev/null assert_unset "__f" "${FUNCNAME[0]}: Flag is not set"
  assert_eq "$f" "false" "${FUNCNAME[0]}: Flag is set"
  >/dev/null assert_eq "$r" "--f" "${FUNCNAME[0]}: Required parameter is set positionally after \"--\""
}

# Too many positional args
test_setargs_19() {
  (
    trap - ERR
    set +e
    (&>/dev/null set_args "-r1= -r2=" "dat1")
    re=$?
    set -e
    >/dev/null assert_not_eq "0" "$re" "${FUNCNAME[0]}: Test should generate error (missing data for required paramere)"
  )
}

# Repeating parameter names
test_setargs_20() {
  (
    trap - ERR
    set +e
    (&>/dev/null set_args "--autocomplete --value=" "5")
    re=$?
    set -e
    >/dev/null assert_not_eq "0" "$re" "${FUNCNAME[0]}: Test should return nonzero (error): Using reserved parameter name"
  )
}

# Illegal characters for parameter name
test_setargs_21() {
  (
    trap - ERR
    set +e
    (&>/dev/null set_args "--test+fail=4" "5")
    re=$?
    set -e
    >/dev/null assert_not_eq "0" "$re" "${FUNCNAME[0]}: Test should return nonzero (error): Using illegal charactetrs for parameter name"
  )
}

# Flags set to default if not given (config {_run_config["declare_optionals"]})
test_setargs_22() {
  declare old_setting="${_run_config["declare_optionals"]}"
  _run_config["declare_optionals"]=1
  set_args "--flag -r= -def=1" "-def" "2" "4"
  eval "$get_args"
  >/dev/null assert_eq "$flag" "$_setargs_optional_false" "${FUNCNAME[0]}: Optional parameters should be set to the default-false value when not given and the config option {_run_config['declare_optionals']} is set"
  >/dev/null assert_eq "$r" "4" "${FUNCNAME[0]}: Optional parameter default (using config option {_run_config['declare_optionals']}) should not interfere with positional/normal parameters"
  >/dev/null assert_eq "$def" "2" "${FUNCNAME[0]}: Optional parameter default (using config option {_run_config['declare_optionals']}) should not interfere with positional/normal parameters"
  _run_config["declare_optionals"]="$old_setting"
}

# Flags set to default if given (config {_run_config["declare_optionals"]})
test_setargs_23() {
  declare old_setting="${_run_config["declare_optionals"]}"
  _run_config["declare_optionals"]=1
  set_args "--f" "--f"
  eval "$get_args"
  >/dev/null assert_eq "$f" "$_setargs_optional_true" "${FUNCNAME[0]}: Optional parameters shold be set to the defualt-true value when given without value and the config option {_run_config['declare_optionals']} is set."
  _run_config["declare_optionals"]="$old_setting"
}

# Flags set to given value (config {_run_config["declare_optionals"]})
test_setargs_24() {
  declare -r old_setting="${_run_config["declare_optionals"]}"
  _run_config["declare_optionals"]=1
  set_args "--f" "--f=my_test"
  eval "$get_args"
  >/dev/null assert_eq "$f" "my_test" "${FUNCNAME[0]}: Optional parameters should be set to the provided value even when config option $${_run_config['declare_optionals']} is set"
  _run_config["declare_optionals"]="$old_setting"
}

# Leftover positional arguments go to argv
test_setargs_25() {
  declare -r old_setting="${_run_config["declare_optionals"]}"
  _run_config["declare_optionals"]=1
  set_args "--" 1 2 "3 4"
  eval "$get_args"
  >/dev/null assert_eq "${#argv[@]}" "3" "${FUNCNAME[0]}: All leftover positional arguments should be set to argv"
  >/dev/null assert_eq "${argv[0]}" "1" "${FUNCNAME[0]}: Leftover positional arguments should be set to argv in order"
  >/dev/null assert_eq "${argv[1]}" "2" "${FUNCNAME[0]}: Leftover positional arguments should be set to argv in order"
  >/dev/null assert_eq "${argv[2]}" '3 4' "${FUNCNAME[0]}: Leftover positional arguments should be set to argv in order"
  _run_config["declare_optionals"]="$old_setting"
}

# Positional arguments should fill parameters first
test_setargs_26() {
  declare -r old_setting="${_run_config["declare_optionals"]}"
  _run_config["declare_optionals"]=1
  set_args "-- -r=" 1 2 "3 4"
  eval "$get_args"
  >/dev/null assert_eq "${r}" "1" "${FUNCNAME[0]}: Positional arguments should fill parameters first"
  >/dev/null assert_eq "${#argv[@]}" "2" "${FUNCNAME[0]}: Only the remaining positional args go to argv"
  >/dev/null assert_eq "${argv[0]}" "2" "${FUNCNAME[0]}: Leftover positional arguments should be set to argv in order"
  >/dev/null assert_eq "${argv[1]}" '3 4' "${FUNCNAME[0]}: Leftover positional arguments should be set to argv in order"
  _run_config["declare_optionals"]="$old_setting"
}

# Positional arguments should fill parameters first
test_setargs_27() {
  declare -r old_setting="${_run_config["declare_optionals"]}"
  _run_config["declare_optionals"]=1
  set_args "-d1=5 -r= -- -d2=6" "-d2" "7" "1" "3 4"
  eval "$get_args"
  >/dev/null assert_eq "${d2}" "7" "${FUNCNAME[0]}: Allowing argv should not change normal assignments"
  >/dev/null assert_eq "${d1}" "1" "${FUNCNAME[0]}: Positional arguments should fill parameters in order"
  >/dev/null assert_eq "${r}" "3 4" "${FUNCNAME[0]}: Positional arguments should fill parameters in order"
  >/dev/null assert_eq "${#argv[@]}" "0" "${FUNCNAME[0]}: There should be no unmached positional arguments left"
  _run_config["declare_optionals"]="$old_setting"
}

test_setargs_helper_28() {
  set_args "--r= --d=d --o" "$@"
  eval "$get_args"
  return 0 # Do nothing
}

test_setargs_helper2_28() {
  set_args "--" "$@"
  eval "$get_args"
  # Do nothing
}

test_setargs_28() {
  echoL "Test output of --autocomplete"
  declare output
  # Silence stderr, stdout contains the word list
  output="$(run_silent 2 test_setargs_helper_28 --autocomplete)"
  declare -r solution=$'--r\n--d\n--o'
  assert_eq "$output" "$solution" "Autocomplete emits word list for parameters"

  output="$(run_silent 2 test_setargs_helper2_28 --autocomplete)"
  declare -r solution2=$''
  assert_eq "$output" "$solution2" "If there are no other parameters the list is empty"
}
