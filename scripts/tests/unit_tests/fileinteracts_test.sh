#!/usr/bin/env false

# version 0.0.0

fileinteracts_test() {
  test_ensure_fd
  test_create_truncate_tmp
  test_canonicalize
  test_checksum_verify_sha256
}

test_ensure_fd() {
  declare -r dir="${dotfiles_test_dir:?}/ensure_directory_file/nest"
  declare -r file="$dir/file"

  command -- rm -rf "$dir"

  [[ ! -f "$file" ]]
  [[ ! -d "$dir" ]]
  declare -i ret
  may_fail ret -- ensure_directory "$dir"
  assert_eq "$ret" "0" "ensure_directory creates nested directories"
  [[ -d "$dir" ]]
  declare output
  output="$(ensure_file "$file")"
  assert_not_eq "$output" "" "ensure_file outputs a message on creation"
  [[ -f "$file" ]]
  output="$(ensure_file "$file")"
  assert_eq "$output" "" "ensure_file does not outputs when the file exists already"
  [[ -f "$file" ]]
}

test_create_truncate_tmp() {
  declare -r name="$RANDOM"
  declare path
  path="$(create_truncate_tmp "$name")"
  assert_match "$path" "/tmp/*/$name" "A file with the given names is created"
  [[ -f "$path" ]]

  # ! (create_truncate_tmp "lillegal_name_/") >&/dev/null;
  assert_returns 1 create_truncate_tmp "lillegal_name_/"
}

test_canonicalize() {
  declare -r dir="/tmp/test_dotfiles/canonicalize"
  ensure_directory "$dir"
  command -- rm -rf "${dir:?}"/*
  (
    cd "$dir" || return
    command -- touch "file"
    command -- ln -s -T "file" "symlink_to_file"
    assert_eq "$(canonicalize_path "file")" "$dir/file" "Relative path must be resoldev"
    assert_eq "$(canonicalize_path "symlink_to_file")" "$dir/file" "Symlinks must be resolved"
    cd ..
    assert_eq "$(is_same_location "canonicalize/file" "$dir/symlink_to_file")" "true" "is_same_location can resolve relative paths and symlinks"
  )
}

test_checksum_verify_sha256() {
  declare -r correct_str="682e0352e1e9f9cc9b5f90125e7f6dc034c7a344371f824d984e0653acaaaec9  ./data/check.txt"
  declare -r incorrect_str="782e0352e1e9f9cc9b5f90125e7f6dc034c7a344371f824d984e0653acaaaec9  ./data/check.txt"
  declare -r correct_str_less_whitespace="682e0352e1e9f9cc9b5f90125e7f6dc034c7a344371f824d984e0653acaaaec9 ./data/check.txt"
  declare output

  checksum_verify_sha256 output "$correct_str"
  assert_eq "$output" "true" "Must identify correct checksum"

  checksum_verify_sha256 output "$incorrect_str"
  assert_eq "$output" "false" "Must identify incorrect checksum"

  checksum_verify_sha256 output "$correct_str_less_whitespace"
  assert_eq "$output" "true" "Must identify correct checksum"
}
