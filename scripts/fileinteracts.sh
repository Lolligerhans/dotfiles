#!/usr/bin/env bash
# ╭──────────────────────╮
# │ 🅅 ersion             │
# ╰──────────────────────╯
# version 0.0.0
# ╭──────────────────────╮
# │ 🛈 Info               │
# ╰──────────────────────╯
# Operations involving the file system
# ╭──────────────────────╮
# │ 🕮  Documentation     │
# ╰──────────────────────╯
# ╭──────────────────────╮
# │ ⚙ Boilerplate        │
# ╰──────────────────────╯
declare -r tag="fileinteracts"
if [[ -v _sourced_files["$tag"] ]]; then return 0; fi
_sourced_files["$tag"]=""
# ╭──────────────────────╮
# │ 🗀 Dependencies       │
# ╰──────────────────────╯
load_version "$dotfiles/scripts/version.sh" 0.0.0
#load_version "$dotfiles/scripts/setargs.sh" 0.0.0;
load_version "$dotfiles/scripts/termcap.sh" 0.0.0
load_version "$dotfiles/scripts/utils.sh" 0.0.0
# ╭──────────────────────╮
# │ 🖩 Utils              │
# ╰──────────────────────╯

ensure_directory() {
  if (($# != 1)); then
    abort "${FUNCNAME[0]}: Expected 1 argument, got $#"
  fi
  if [[ ! -d "$1" ]]; then
    mkdir -vp "$1"
  fi
}

ensure_file() {
  if [[ ! -f "${1:?Missing filename}" ]]; then
    echo "Creating file $text_di$1"
    touch "$1"
  fi
}

# Create or truncate file $1 at a fixed location below /tmp/
# Outputs full path.
create_truncate_tmp() {
  declare -r dir="/tmp/dotfiles_tmp/"
  if (($# != 1)); then
    errcho "Expected 1 argument, got $#"
    abort "Wrong usage"
  fi
  if [[ "${1:?Expected filename}" != +([[:word:]]) ]]; then
    abort "Only simple characters allowed: $1"
  fi
  >/dev/null ensure_directory "$dir"
  declare -r full_path="$dir/$1"
  if [[ ! -f "$full_path" ]]; then
    touch "$full_path"
  else
    truncate -s 0 "$full_path"
  fi
  # echoi "${FUNCNAME[0]}: full_path=$full_path";
  printf "%s" "$full_path"
  return 0
}

# Return the parent directory of a file.
# $1 (in)  The file
# Output: The parent directory
parent_dir_of() {
  if (($# != 1)); then
    abort "${FUNCNAME[0]}: Expected 1 argument, got $#"
  fi
  declare parent_dir
  parent_dir="$(dirname -- "$(realpath -- "$1")")"
  show_variable
  dirname -- "$1"
  izz
}

# Create randomly named directory somewhere below /tmp. No guarantee that it is
# unique, but likely is.
# Output: absolute path to new directory.
random_tmp() {
  declare -r full_path="/tmp/rt/$RANDOM"
  ensure_directory "$full_path"
  printf "%s" "$full_path"
}

# TODO Currently not needed
same_file_linked() {
  if (("$#" != 2)); then
    abort "usage: 'same_file_linked $file1 $file2'"
  fi
  [[ "$(readlink -f "$1")" -ef "$(readlink -f "$2")" ]]
}

# Download to ~/Downloads/ and verify SHA256
# $1  (in)  Link
# $2  (in)  SHA256 as hex string
# $3  (in, optional)  Filename that wget will create. Will use $(basename $link)
#                     if missing.
# Make sure link matches the filename in the test string!
wget_verify_sha256() {
  if (("$#" < 2 || 3 < "$#")); then
    abort "usage: '${FUNCNAME[0]} $link $sha256 [$filaname]'"
  fi

  declare -r link="${1:?Missing link}"
  declare -r filename="${3:-$(command basename -- "$1")}"
  declare -r verify_string="${2:?Missing checksum}  ${filename}"
  show_variable link
  show_variable filename
  show_variable verify_string

  echol "Get: $filename ($link)"
  pushd "${HOME}/Downloads" || return

  command wget --quiet --continue --show-progress "$link" || true

  declare verify="false"
  checksum_verify_sha256 verify "${verify_string}"
  if [[ "$verify" != "true" ]]; then
    command mv -vf "${filename}" "${filename}.bad"
    errchoe "Failed to verify checksum"
    return 1
  fi

  popd || return
  echok Got: "$filename"
}

# $1  (out)  Output variable (set to "true" or "false")
# $2  (in)   sha256sum test string (e.g., "b94d2...7b99 test.txt")
# This function allows writing the result of sha256sum -c into a variable
# (instead of returning 0 or 1).
checksum_verify_sha256() {
  if (("$#" != 2)); then
    abort "usage: '${FUNCNAME[0]} out_var $file $checksum'"
  fi

  # Sanity checks
  if [[ "$-" != *e* ]]; then
    errchoe "${FUNCNAME[0]} needs set -e"
    abort "Need set -e to continue"
  fi
  if ! sha256sum --version &>/dev/null; then
    errchoe "${FUNCNAME[0]} requires sha256sum"
    abort "Need sha256sum to continue"
  fi

  declare -n _vcs_934712384_="${1}"
  if sha256sum -c <<<"$2"; then
    printf -v _vcs_934712384_ -- "true"
  else
    printf -v _vcs_934712384_ -- "false"
    errchow "Failed checksum verification for $text_dim$1$text_normal"
  fi
}

# ❕ We use the set -e mechanism to abort when the checksum is incorrect.
# Return 0 is checksum ok, else 1
#
# $1  file path
# $2  sha256 output
test_checksum() {
  echou "Deprecated use of test_checksum. Use checksum_verify_sha256 instead. Use verify_checksum insteadd"

  if (("$#" != 2)); then
    abort "${FUNCNAME[0]}: usage: 'checksum $file $checksum'"
  fi

  # TODO For now, require set -e. if we have a good reason remove later.
  if [[ "$-" != *e* ]]; then
    errchoe "Checksum needs set -e"
    exit 1
  fi

  declare -r expected="${2:?Error}"
  declare computed
  comupted="$(sha256sum "${1:?Error}")"
  if [[ "$computed" == "$expected" ]]; then
    return 0
  else
    errchoe "Checksum failed for $text_dim$1$text_normal"
    return 1
  fi
}

# Print full path of file $1. Resolve symlinks.
# Outputs path.
canonicalize_path() {
  realpath -e "${1:?Missing path}"
}

# Check if paths $1 and $2 describe the same location. Resolving symlinks and
# relative links. Cannot understand matching hardlinks.
# Output "true" or "false".
is_same_location() {
  declare p1 p2
  p1="$(canonicalize_path "${1:?Missing path}")"
  p2="$(canonicalize_path "${2:?Missing path}")"
  if [[ "${p1}" == "${p2}" ]]; then
    printf -- "true"
  else
    printf -- "false"
  fi
}
