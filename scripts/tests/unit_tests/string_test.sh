#!/usr/bin/env false

# version 0.0.0

string_test() {
  test_array_to_ascii
  test_common_prefix
  test_string_to_array
}

# ╭────────────────────────────────────────────────────────────╮
# │ Test functions                                             │
# ╰────────────────────────────────────────────────────────────╯

test_array_to_ascii() {
  echoL "Test regular, intended use"
  declare -ar input=(1 2 '$' " " \' \")
  declare -a output=()
  array_to_ascii output input
  show_variable output
  assert_eq "${#output[@]}" "6" "Output should have 6 elements"
  assert_eq "${output[0]}" "49" "First char is correct"
  assert_eq "${output[1]}" "50" "Second char is correct"
  assert_eq "${output[2]}" '36' "Dollar is correct"
  assert_eq "${output[3]}" "32" "Space is correct"
  assert_eq "${output[4]}" "39" "Quote is correct"
  assert_eq "${output[5]}" "34" "Double quote is correct"
  assert_eq "${output[@]@A}" 'declare -a output=([0]="49" [1]="50" [2]="36" [3]="32" [4]="39" [5]="34")' "Exact match for generated output"

  assert_eq "${input[@]@A}" 'declare -ar input=([0]="1" [1]="2" [2]="\$" [3]=" " [4]="'\''" [5]="\"")' "Input must remain unchanged"

  echoL "Test requirement for empty output array"
  declare -a not_empty_output=(1)
  assert_returns 1 array_to_ascii not_empty_output input

  echoL "testing for emtpy transformation"
  declare -ar input3=()
  declare -a output3=()
  array_to_ascii output3 input3
  show_variable output3
  assert_eq "${#output3[@]}" "0" "Output should be empty"
  assert_eq "${output3[@]@A}" "declare -a output3=()" "Exact match for generated output"
}

test_common_prefix() {
  declare -ar inputs=("123cd" "123" "123b" "123a")
  declare res
  res="$(common_prefix "${inputs[@]}")"
  assert_eq "$res" "123" "Common prefix is correct"
}

test_remove_ansi_escapes() {
  echol "${FUNCNAME[0]}"
  declare -r input2="$(
    cat <<-EOF
		[2m[38;2;255;144;192malias(B[m[2m…(B[mManage local alias(B[m
		EOF
  )"
  show_variable input
  declare output
  remove_ansi_escapes "$input2"
  echo
  output="$(remove_ansi_escapes "$input2")"
  assert_eq "$output" "alias…Manage local alias" "Escape sequences are removed"
}

test_repeat_string() {
  declare -r input4="' "
  declare -i count=3

  declare output

  repeat_string "$count" "$input4" output
  assert_eq "$output" "' ' ' " "Input should be repeated 3 times"

  repeat_string "0" "$input4" output
  assert_eq "$output" "" "Zero repetitions should be empty"
}

test_string_to_array() {
  declare -r input2=12\$\ \'\"
  declare -a output=()
  string_to_array output "$input2"
  assert_eq "${#output[@]}" 6 "Output should have 6 elements"
  assert_eq "${output[0]}" "1" "First char is correct"
  assert_eq "${output[1]}" "2" "Second char is correct"
  assert_eq "${output[2]}" '$' "Dollar is correct"
  assert_eq "${output[3]}" " " "Space is correct"
  assert_eq "${output[4]}" \' "Quote is correct"
  assert_eq "${output[5]}" \" "Double quote is correct"
}
