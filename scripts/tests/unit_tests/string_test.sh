#!/usr/bin/env false

# version 0.0.0

string_test() {
  test_common_prefix
}

# ╭────────────────────────────────────────────────────────────╮
# │ Test functions                                             │
# ╰────────────────────────────────────────────────────────────╯

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
  declare -r input="' "
  declare -i count=3

  declare output

  repeat_string "$count" "$input" output
  assert_eq "$output" "' ' ' " "Input should be repeated 3 times"

  repeat_string "0" "$input" output
  assert_eq "$output" "" "Zero repetitions should be empty"
}
