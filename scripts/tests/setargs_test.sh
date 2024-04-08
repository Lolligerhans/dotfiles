#!/usr/bin/env bash

# version 0.0.0

# These functions belong to commands_test.sh but we store them here because
# they are so plentyful.

# Source setargs.sh in the file you are sourcing this

# Used from working dir ~/dotfiles/

test_setargs_1()
{
  >/dev/null assert_eq "${_run_config["declare_optionals"]}" "0" "${FUNCNAME}: This function runs in old mode";
  set_args "--r=" "--r=r_val"
  declare -r r="$__r";
  unset_args
  >/dev/null assert_eq "$r" "r_val" "${FUNCNAME}: Required value must be set"
}

test_setargs_2()
{
  set_args "--d=d"
  >/dev/null assert_eq "$__d" "d" "${FUNCNAME}: Default value must be set"
  unset_args
}

test_setargs_3()
{
  set_args "--d=d" --d=changed
  >/dev/null assert_eq "$__d" "changed" "${FUNCNAME}: Default value must be changed"
  unset_args
}

test_setargs_4()
{
  set_args "--r=" "required"
  >/dev/null assert_eq "$__r" "required" "${FUNCNAME}: Required parameter must be set positionally"
  unset_args
}

test_setargs_5()
{
  set_args "--d=d" "non-default"
  >/dev/null assert_eq "$__d" "non-default" "${FUNCNAME}: Default parameter must be set positionally"
  unset_args
}

test_setargs_6()
{
  set_args "--f" "--f"
  >/dev/null assert_eq "$__f" "" "${FUNCNAME}: Flag must be set"
  unset_args
}

test_setargs_7()
{
  set_args "--f --d=d" "alternative"
  >/dev/null assert_unset "__f" "${FUNCNAME}: Flag must not be set";
  >/dev/null assert_eq "$__d" "alternative" "${FUNCNAME}: Default parameter must be set positionally"
  unset_args
}

test_setargs_8()
{
  set_args "--f --d=d --d2=d2" "alternative"
  >/dev/null assert_unset "__f" "${FUNCNAME}: Flag must not be set";
  >/dev/null assert_eq "$__d" "alternative" "${FUNCNAME}: Default parameter must be set positionally"
  >/dev/null assert_eq "$__d2" "d2" "${FUNCNAME}: Default parameter 2 must be defaulted"
  unset_args
}

test_setargs_9()
{
  set_args "--f --r= --d=d --d2=d2" "alternative"
  >/dev/null assert_unset "__f" "${FUNCNAME}: Flag must not be set";
  >/dev/null assert_eq "$__r" "alternative" "${FUNCNAME}: First param gets the data"
  >/dev/null assert_eq "$__d" "d" "${FUNCNAME}: Default parameter must be defaulted"
  >/dev/null assert_eq "$__d2" "d2" "${FUNCNAME}: Default parameter 2 must be defaulted"
  unset_args
}

test_setargs_10()
{
  set_args "--f --r= -r2= -f2 --d=d --d2=d2" "dat1" "dat2" "-f2" "-r2=r2"
  >/dev/null assert_unset "__f" "${FUNCNAME}: Flag must not be set";
  >/dev/null assert_eq "$__r" "dat1" "${FUNCNAME}: Required 1 set by data1"
  >/dev/null assert_eq "$_r2" "r2" "${FUNCNAME}: Required 2 explcitly"
  >/dev/null assert_eq "$_f2" "" "${FUNCNAME}: Flag 2 must be set";
  >/dev/null assert_eq "$__d" "dat2" "${FUNCNAME}: Default parameter 1 is fed data2"
  >/dev/null assert_eq "$__d2" "d2" "${FUNCNAME}: Default parameter 2 must be defaulted"
  unset_args
}

test_setargs_11()
{
  set_args "--r=" "--r" "req"
  >/dev/null assert_eq "$__r" "req" "${FUNCNAME}: Required parameter gets split data"
  unset_args
}

test_setargs_12()
{
  set_args "-d=d --r=" "--r" "req"
  >/dev/null assert_eq "$_d" "d" "${FUNCNAME}: Default parameter has default value"
  >/dev/null assert_eq "$__r" "req" "${FUNCNAME}: Required parameter gets split data"
  unset_args
}

# Differentiate between positional and split argument data, when order differes
test_setargs_13()
{
  set_args "--r= -r2= -d=d" "positional" "--r" "split"
  >/dev/null assert_eq "$__r" "split" "${FUNCNAME}: Required parameter gets explicit split data"
  >/dev/null assert_eq "$_r2" "positional" "${FUNCNAME}: Required parameter 2 gets data argument"
  >/dev/null assert_eq "$_d" "d" "${FUNCNAME}: Default parameter has default value"
  unset_args
}

# Just a wild test without pattern
test_setargs_14()
{
  set_args "-r1= -f1 -d1=d1 --r2= --f2 --d2=d2 -r3= -f3 -d3=d3"\
    "--d2=d 2" --r2 "r 2" -f3 r_1 -r3=-r_3 d_1 -f1
  >/dev/null assert_eq "$_r1" r_1 "${FUNCNAME}: Required 1 is set positionally"
  >/dev/null assert_eq "$_f1" "" "${FUNCNAME}: Flag 1 is set"
  >/dev/null assert_eq "$_d1" d_1 "${FUNCNAME}: Default 1 is set positionally"
  >/dev/null assert_eq "$__r2" "r 2" "${FUNCNAME}: Required 2 is set by split data"
  >/dev/null assert_unset "__f2" "${FUNCNAME}: Flag 2 is not set"
  >/dev/null assert_eq "$__d2" "d 2" "${FUNCNAME}: Default 1 is set explicitly"
  >/dev/null assert_eq "$_r3" -r_3 "${FUNCNAME}: Required 3 is set directly"
  >/dev/null assert_eq "$_f3" "" "${FUNCNAME}: Flag 3 is set"
  >/dev/null assert_eq "$_d3" "d3" "${FUNCNAME}: Default 3 is left at default value";
  unset_args
}

# Typical use case:
#  - Required parameters first
#  - Positional arguments first
test_setargs_15()
{
  set_args "-r1= -r2= -r3= -d1=d1 -d2=d2 -d3=d3 --f1 --f2"\
    -d3 d_3 --f1=test "r_1" -r3 r_3 -d2=d_2 "r_2"
  >/dev/null assert_eq "$_r1" r_1 "${FUNCNAME}: Required 1 is set positionally"
  >/dev/null assert_eq "$_r2" r_2 "${FUNCNAME}: Required 2 is set positionally"
  >/dev/null assert_eq "$_r3" r_3 "${FUNCNAME}: Required 2 is set by split data"
  >/dev/null assert_eq "$_d1" d1 "${FUNCNAME}: Default 1 is set to default"
  >/dev/null assert_eq "$_d2" d_2 "${FUNCNAME}: Default 2 is set explicitly"
  >/dev/null assert_eq "$_d3" d_3 "${FUNCNAME}: Default 3 is set by split data"
  >/dev/null assert_eq "$__f1" "test" "${FUNCNAME}: Flag 1 is set"
  >/dev/null assert_unset "__f2" "${FUNCNAME}: Flag 2 is not set"
  unset_args
}

# Missing force argument
test_setargs_16()
{
  # Some boilerplate for negative tests:
  (
  trap - ERR
  set +e;
  (
  &>/dev/null set_args "-r1=";
  );
  re=$?
  set -e
  >/dev/null assert_not_eq "0" "$re" "${FUNCNAME}: Test should generate error"
  >/dev/null assert_unset "_r1" "${FUNCNAME}: Invalid parameter should remain unset"
  );
}


# Too many positional args
test_setargs_17()
{
  (
  trap - ERR
  set +e;
  ( &>/dev/null set_args "-r1=" "dat1" dat2)
  re=$?
  set -e
  >/dev/null assert_not_eq "0" "$re" "${FUNCNAME}: Test should generate error"
  );
}

# Double dash to force positional data
test_setargs_18()
{
  set_args "--f -r=" "--" "--f";
  >/dev/null assert_unset "__f" "${FUNCNAME}: Flag is not set"
  >/dev/null assert_eq "$_r" "--f" "${FUNCNAME}: Required parameter is set positionally after \"--\""
  unset_args;
}

# Too many positional args
test_setargs_19()
{
  (
  trap - ERR
  set +e;
  ( &>/dev/null set_args "-r1= -r2=" "dat1")
  re=$?
  set -e
  >/dev/null assert_not_eq "0" "$re" "${FUNCNAME}: Test should generate error (missing data for required paramere)"
  );
}

# Repeating parameter names
test_setargs_20()
{
  (
  trap - ERR;
  set +e;
  ( &>/dev/null set_args "--autocomplete --value=" "5");
  re=$?;
  set -e;
  >/dev/null assert_not_eq "0" "$re" "${FUNCNAME}: Test should return nonzero (error): Using reserved parameter name";
  );
}

# Illegal characters for parameter name
test_setargs_21()
{
  (
  trap - ERR;
  set +e;
  ( &>/dev/null set_args "--test+fail=4" "5");
  re=$?;
  set -e;
  >/dev/null assert_not_eq "0" "$re" "${FUNCNAME}: Test should return nonzero (error): Using illegal charactetrs for parameter name";
  );
}

# Flags set to default if not given (config {_run_config["declare_optionals"]})
test_setargs_22()
{
  declare old_setting="${_run_config["declare_optionals"]}";
  _run_config["declare_optionals"]=1;
  set_args "--flag -r= -def=1" "-def" "2" "4";
  eval "$get_args";
  >/dev/null assert_eq "$flag" "$_setargs_optional_false" "${FUNCNAME}: Optional parameters should be set to the default-false value when not given and the config option {_run_config['declare_optionals']} is set";
  >/dev/null assert_eq "$r" "4" "${FUNCNAME}: Optional parameter default (using config option {_run_config['declare_optionals']}) should not interfere with positional/normal parameters";
  >/dev/null assert_eq "$def" "2" "${FUNCNAME}: Optional parameter default (using config option {_run_config['declare_optionals']}) should not interfere with positional/normal parameters";
  _run_config["declare_optionals"]="$old_setting";
}

# Flags set to default if given (config {_run_config["declare_optionals"]})
test_setargs_23()
{
  declare old_setting="${_run_config["declare_optionals"]}";
  _run_config["declare_optionals"]=1;
  set_args "--f" "--f";
  eval "$get_args";
  >/dev/null assert_eq "$f" "$_setargs_optional_true" "${FUNCNAME}: Optional parameters shold be set to the defualt-true value when given without value and the config option {_run_config['declare_optionals']} is set.";
  _run_config["declare_optionals"]="$old_setting";
}

# Flags set to given value (config {_run_config["declare_optionals"]})
test_setargs_24()
{
  declare -r old_setting="${_run_config["declare_optionals"]}";
  _run_config["declare_optionals"]=1;
  set_args "--f" "--f=my_test";
  eval "$get_args";
  >/dev/null assert_eq "$f" "my_test" "${FUNCNAME}: Optional parameters should be set to the provided value even when config option $${_run_config['declare_optionals']} is set";
  _run_config["declare_optionals"]="$old_setting";
}

# Leftover positional arguments go to argv
test_setargs_25()
{
  declare -r old_setting="${_run_config["declare_optionals"]}";
  _run_config["declare_optionals"]=1;
  set_args "--" 1 2 "3 4";
  eval "$get_args";
  >/dev/null assert_eq "${#argv[@]}" "3" "${FUNCNAME}: All leftover positional arguments should be set to argv";
  >/dev/null assert_eq "${argv[0]}" "1" "${FUNCNAME}: Leftover positional arguments should be set to argv in order";
  >/dev/null assert_eq "${argv[1]}" "2" "${FUNCNAME}: Leftover positional arguments should be set to argv in order";
  >/dev/null assert_eq "${argv[2]}" '3 4' "${FUNCNAME}: Leftover positional arguments should be set to argv in order";
  _run_config["declare_optionals"]="$old_setting";
}

# Positional arguments should fill parameters first
test_setargs_26()
{
  declare -r old_setting="${_run_config["declare_optionals"]}";
  _run_config["declare_optionals"]=1;
  set_args "-- -r=" 1 2 "3 4";
  eval "$get_args";
  >/dev/null assert_eq "${r}" "1" "${FUNCNAME}: Positional arguments should fill parameters first";
  >/dev/null assert_eq "${#argv[@]}" "2" "${FUNCNAME}: Only the remaining positional args go to argv";
  >/dev/null assert_eq "${argv[0]}" "2" "${FUNCNAME}: Leftover positional arguments should be set to argv in order";
  >/dev/null assert_eq "${argv[1]}" '3 4' "${FUNCNAME}: Leftover positional arguments should be set to argv in order";
  _run_config["declare_optionals"]="$old_setting";
}

# Positional arguments should fill parameters first
test_setargs_27()
{
  declare -r old_setting="${_run_config["declare_optionals"]}";
  _run_config["declare_optionals"]=1;
  set_args "-d1=5 -r= -- -d2=6" "-d2" "7" "1" "3 4";
  eval "$get_args";
  >/dev/null assert_eq "${d2}" "7" "${FUNCNAME}: Allowing argv should not change normal assignments";
  >/dev/null assert_eq "${d1}" "1" "${FUNCNAME}: Positional arguments should fill parameters in order";
  >/dev/null assert_eq "${r}" "3 4" "${FUNCNAME}: Positional arguments should fill parameters in order";
  >/dev/null assert_eq "${#argv[@]}" "0" "${FUNCNAME}: There should be no unmached positional arguments left";
  _run_config["declare_optionals"]="$old_setting";
}

# ❗ Don't forget up update test counter in script
#
#       ~/dotfiles/scripts/tests/commands_test.sh command_test_setargs_all test
#
# when adding new tests! # TODO This could also be automated...
