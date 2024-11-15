#!/usr/bin/env false

# version 0.0.0

fileinteracts_test() {
  test_ensure_fd;
  test_create_truncate_tmp;
  test_canonicalize;
}

test_ensure_fd() {
  declare -r dir="${dotfiles_test_dir:?}/ensure_directory_file/nest";
  declare -r file="$dir/file";

  command -- rm -rf "$dir";

  [[ ! -f "$file" ]];
  [[ ! -d "$dir" ]];
  declare -i ret;
  may_fail ret -- ensure_directory "$dir";
  assert_eq "$ret" "0" "ensure_directory creates nested directories";
  [[ -d "$dir" ]];
  declare output;
  output="$(ensure_file "$file")";
  assert_not_eq "$output" "" "ensure_file outputs a message on creation";
  [[ -f "$file" ]];
  output="$(ensure_file "$file")";
  assert_eq "$output" "" "ensure_file does not outputs when the file exists already";
  [[ -f "$file" ]];
}

test_create_truncate_tmp() {
  declare -r name="$RANDOM";
  declare path;
  path="$(create_truncate_tmp "$name")";
  assert_match "$path" "/tmp/*/$name" "A file with the given names is created";
  [[ -f "$path" ]];

  # ! (create_truncate_tmp "lillegal_name_/") >&/dev/null;
  assert_returns 1 create_truncate_tmp "lillegal_name_/";
}

test_canonicalize() {
  declare -r dir="/tmp/test_dotfiles/canonicalize";
  ensure_directory "$dir";
  command -- rm -rf "${dir:?}"/*;
  (
    cd "$dir" || return;
    command -- touch "file";
    command -- ln -s -T "file" "symlink_to_file";
    assert_eq "$(canonicalize_path "file")" "$dir/file" "Relative path must be resoldev";
    assert_eq "$(canonicalize_path "symlink_to_file")" "$dir/file" "Symlinks must be resolved";
    cd ..;
    assert_eq "$(is_same_location "canonicalize/file" "$dir/symlink_to_file")" "true" "is_same_location can resolve relative paths and symlinks";
  );
}

