#!/usr/bin/env bash
# ╭──────────────────────╮
# │ 🅅 ersion             │
# ╰──────────────────────╯
# version 0.0.0
# ╭──────────────────────╮
# │ 🛈 Info               │
# ╰──────────────────────╯
# System script that contains helpers to query system information
# ╭──────────────────────╮
# │ ⚙ Boilerplate        │
# ╰──────────────────────╯
declare -r tag="system_script"
if [[ -v _sourced_files["$tag"] ]]; then return 0; fi
_sourced_files["$tag"]=""
# ╭──────────────────────╮
# │ 🗀 Dependencies       │
# ╰──────────────────────╯
# ✔ Ensure versions with satisfy_version
satisfy_version "$dotfiles/scripts/boilerplate.sh" "0.0.0"
# ✔ Source versioned dependencies with load_version
load_version "$dotfiles/scripts/version.sh" "0.0.0"
#load_version "$dotfiles/scripts/assert.sh"
#load_version "$dotfiles/scripts/bash_meta.sh"
#load_version "$dotfiles/scripts/cache.sh"
#load_version "$dotfiles/scripts/error_handling.sh"
#load_version "$dotfiles/scripts/fileinteracts.sh"
#load_version "$dotfiles/scripts/git_utils.sh"
#load_version "$dotfiles/scripts/progress_bar.sh"
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

# Test if current system is Ubuntu of specified major version
#   • $1  (in)  Version to test for
#   • [$2  (out)  Result-variable, else result goes to stdout. Optional.]
#   • Out: "y" if system is Ubuntu of specified major version, else "n".
is_ubuntu_version() {
  if (($# < 1 || 2 < $#)); then
    abort "Wrong usage"
  fi
  # Use high entropy names to avoid name conflicts
  declare _iuv_result_13098130581 # Temporary storage when $2 is not set
  declare _iuv_return_751038403850341="${2-"_iuv_result_13098130581"}"
  declare is_ubuntu_str
  is_ubuntu_str="$(lsb_release -ds)" # Example value: 'Ubuntu 22.04 LTS'
  if [[ "$is_ubuntu_str" != "Ubuntu"* ]]; then
    _iuv_return_751038403850341="n"
  else
    declare version_string
    version_string="$(lsb_release -sr)" # Example value: '22.04'
    if [[ "$version_string" != "${1}."* ]]; then
      _iuv_return_751038403850341="n"
    else
      _iuv_return_751038403850341="y"
    fi
  fi
  # When no result variable was given, print to stdout
  if (($# < 2)); then
    printf "%s" "$_iuv_return_751038403850341"
  fi
}

# ╭──────────────────────╮
# │ 🖹 Help strings       │
# ╰──────────────────────╯
# ╭──────────────────────╮
# │ 🕮  Documentation     │
# ╰──────────────────────╯
