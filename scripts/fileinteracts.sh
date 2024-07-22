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
declare -r tag="fileinteracts";
if [[ -v _sourced_files["$tag"] ]]; then return 0; fi
_sourced_files["$tag"]="";
# ╭──────────────────────╮
# │ 🗀 Dependencies       │
# ╰──────────────────────╯
load_version "$dotfiles/scripts/version.sh" 0.0.0;
#load_version "$dotfiles/scripts/setargs.sh" 0.0.0;
load_version "$dotfiles/scripts/termcap.sh" 0.0.0;
load_version "$dotfiles/scripts/utils.sh" 0.0.0;
# ╭──────────────────────╮
# │ 🖩 Utils              │
# ╰──────────────────────╯

ensure_directory()
{
  if (($# != 1)); then
    abort "$FUNCNAME: Expected 1 argument, got $#";
  fi
  if [[ ! -d "$1" ]]; then
    mkdir -vp "$1";
  fi
}

ensure_file()
{
  if [ "$#" -ne "1" ]; then
    echo "Wrong usage";
    return 1;
  fi

  if [ ! -f "$1" ]; then
    echo "Creating file [$1]";
    touch "$1";
    return "$?";
  fi
}

# Create or truncate file $1 anywhere within /tmp/... Outputs full path.
create_truncate_tmp()
{
  if (( $# != 1 )); then
    errcho "Expected 1 argument, got $#";
    abort "Wrong usage";
  fi
  >/dev/null ensure_directory "/tmp/ctt";
  declare -r full_path="/tmp/ctt/$1";
  if [[ ! -f "$full_path" ]]; then
    touch "$full_path";
  else
    truncate -s 0 "$full_path";
  fi
#  echoi "$FUNCNAME: full_path=$full_path";
  printf "%s" "$full_path";
  return 0;
}

# Create randomly named directory somewhere below /tmp. No guarantee that it is
# unique, but likely is.
# Output: absolute path to new directory.
random_tmp()
{
  declare -r full_path="/tmp/rt/$RANDOM";
  ensure_directory "$full_path";
  printf "%s" "$full_path";
}

# TODO Currently not needed
same_file_linked()
{
  if (("$#" != 2)); then
    abort "usage: 'same_file_linked $file1 $file2'";
  fi
  [[ "$(readlink -f "$1")" -ef "$(readlink -f "$2")" ]];
}


# $1  (out)  Output variable (set to "true" or "false")
# $2  (in)   sha256sum test string (e.g., "b94d2...7b99 test.txt")
# This function allows writing the result of sha256sum -c into a variable
# (instead of returning 0 or 1).
checksum_verify_sha256()
{
  if (("$#" != 2)); then
    abort "$FUNCNAME: usage: '${FUNCNAME[0]} out_var $file $checksum'";
  fi

  # Sanity checks
  if [[ "$-" != *e* ]]; then
    errchoe "${FUNCNAME[0]} needs set -e";
    abort "Need set -e to continue";
  fi
  if ! sha256sum --version &>/dev/null; then
    errchoe "${FUNCNAME[0]} requires sha256sum";
    abort "Need sha256sum to continue";
  fi

  declare -n _vcs_934712384_="${1}";
  if sha256sum -c <<< "$2"; then
    printf -v _vcs_934712384_ -- "true";
  else
    printf -v _vcs_934712384_ -- "false";
    errchow "Failed checksum verification for $text_dim$1$text_normal";
  fi
}

# ❕ We use the set -e mechanism to abort when the checksum is incorrect.
# Return 0 is checksum ok, else 1
#
# $1  file path
# $2  sha256 output
test_checksum()
{
  echou "Deprecated use of test_checksum. Use checksum_verify_sha256 instead. Use verify_checksum insteadd";

  if (("$#" != 2)); then
    abort "$FUNCNAME: usage: 'checksum $file $checksum'";
  fi

  # TODO For now, require set -e. if we have a good reason remove later.
  if [[ "$-" != *e* ]]; then
    errchoe "Checksum needs set -e";
    exit 1;
  fi

  declare -r expected="${2:?Error}";
  declare computed;
  comupted="$(sha256sum "${1:?Error}")";
  if [[ "$computed" == "$expected" ]]; then
    return 0;
  else
    errchoe "Checksum failed for $text_dim$1$text_normal";
    return 1;
  fi
}
