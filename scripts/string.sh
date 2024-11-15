#!/usr/bin/env false
# ╭──────────────────────╮
# │ 🅅 ersion             │
# ╰──────────────────────╯
# version 0.0.0
# ╭──────────────────────╮
# │ 🛈 Info               │
# ╰──────────────────────╯
# String utils for Bash
# ╭──────────────────────╮
# │ ⚙ Boilerplate        │
# ╰──────────────────────╯
declare -r tag="strings"
if [[ -v _sourced_files["$tag"] ]]; then return 0; fi
_sourced_files["$tag"]=""
# ╭──────────────────────╮
# │ 🗀 Dependencies       │
# ╰──────────────────────╯
# ✔ Ensure versions with satisfy_version
satisfy_version "$dotfiles/scripts/boilerplate.sh" "0.0.0";
# ✔ Source versioned dependencies with load_version
load_version "$dotfiles/scripts/version.sh" "0.0.0";
#load_version "$dotfiles/scripts/assert.sh"
#load_version "$dotfiles/scripts/bash_meta.sh"
#load_version "$dotfiles/scripts/cache.sh"
#load_version "$dotfiles/scripts/error_handling.sh"
#load_version "$dotfiles/scripts/fileinteracts.sh"
#load_version "$dotfiles/scripts/git_utils.sh"
#load_version "$dotfiles/scripts/progress_bar.sh"
#load_version "$dotfiles/scripts/nyx/nyx.sh"
#load_version "$dotfiles/scripts/setargs.sh"
#load_version "$dotfiles/scripts/termcap.sh"
#load_version "$dotfiles/scripts/userinteracts.sh"
#load_version "$dotfiles/scripts/utils.sh"
# ╭──────────────────────╮
# │ 🗺 Globals           │
# ╰──────────────────────╯
# ╭──────────────────────╮
# │ 🖩 Utils              │
# ╰──────────────────────╯
# ╭──────────────────────╮
# │ 𝑓 Functional         │
# ╰──────────────────────╯

common_prefix() {
  # https://stackoverflow.com/a/17475354
  printf "%s\n" "$@" | sed -e '$!{N;s/^\(.*\).*\n\1.*$/\1\n\1/;D;}'
}

# Remove color escape sequences from string
# - $1: input string
# - stdout: string with escape sequences removed
remove_ansi_escapes() {
  if ! shopt -p extglob >/dev/null; then
    abort "extglob required"
  fi

  if (($# != 1)); then
    abort "Requires 1 argument"
  fi

  declare -r escape=$'\e'
  # We regex for the general "escape sequence" format
  #     ESC general_intermediateBytes general_finalByte
  # - https://en.wikipedia.org/wiki/ISO/IEC_2022
  # - https://www.ecma-international.org/wp-content/uploads/ECMA-35_6th_edition_december_1994.pdf
  declare -r general_intermediateByte=$'[\x20-\x2f]'
  declare -r general_intermediateBytes="*($general_intermediateByte)"
  declare -r general_finalByte=$'[\x30-\x7e]'
  # We further regex for the ANSI color code format:
  #     CSI color_parameterBytes color_intermediateBytes color_finalByte
  # where CSI follows the general format by choosing zero intermediate bytes:
  #     ESC [
  # - https://en.wikipedia.org/wiki/ANSI_escape_code#cite_note-ECMA-48-5
  # - ISO 6429
  declare -r controlSequenceIntroducer=$'\e'"\["
  declare -r color_parameterByte=$'[\x30-\x3f]' # 0–9:;<=>?
  declare -r color_parameterBytes="*($color_parameterByte)"
  declare -r color_intermediateByte=$'[\x20-\x2f]' # !"#$%&'()*+,-./
  declare -r color_intermediateBytes="*($color_intermediateByte)"
  declare -r color_finalByte=$'[\x40-\x7e]' # @A–Z[\]^_`a–z{|}~

  declare cleaned

  # Combined pattern that does not follow the format strictly but needs only
  # a single pattern for both. We do not use it.
  # printf -- "%s" "${1//${escape}?(\[)${color_parameterBytes}${color_intermediateBytes}${color_finalByte}/}"

  # Color
  # ESC[ [param...] [intermediate...] final
  printf -v cleaned -- "%s" "${1//${controlSequenceIntroducer}${color_parameterBytes}${color_intermediateBytes}${color_finalByte}/}"

  # General
  # ESC [intermadiate...] final
  >&2 show_variable cleaned
  printf -- "%s" "${cleaned//${escape}${general_intermediateBytes}${general_finalByte}/}"
}

# $1: repetition count
# ($2: character)
# ($3: output variable name)
# If $3 is given, writes variable. Else writes to stdout.
repeat_string() {
  declare -i count="${1}"
  declare str="${2:-"="}"
  declare res
  printf -v res -- "%${count}s"
  res="${res// /"$str"}"
  if (($# == 3)); then
    declare -n _repeat_string__ref="${3}"
    printf -v _repeat_string__ref -- "%s" "$res"
  else
    printf -- "%s" "${res}"
  fi
  return 0
}

# ╭──────────────────────╮
# │ 🖹 Help strings       │
# ╰──────────────────────╯
# ╭──────────────────────╮
# │ 🕮  Documentation     │
# ╰──────────────────────╯
