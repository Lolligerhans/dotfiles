#!/usr/bin/env bash
# ╭──────────────────────╮
# │ 🅅 ersion             │
# ╰──────────────────────╯
# version 0.0.0

# ╭──────────────────────╮
# │ ⚙ Boilerplate        │
# ╰──────────────────────╯
if [[ -v _sourced_files["userinteracts"] ]]; then
  #  errchof "Not loading userinteracts"
  return 0
fi
_sourced_files["userinteracts"]=""
#errchof "Loading userinteracts"
# ╭──────────────────────╮
# │ 🗀 Dependencies       │
# ╰──────────────────────╯
# shellcheck source=scripts/utils.sh
source "$dotfiles/scripts/utils.sh"

# ╭──────────────────────╮
# │ 🖩 Utils              │
# ╰──────────────────────╯

# 1-tap version of boolean_prompt. Prints "true" or "false".
# if $2 is given, output is assigned to it by reference.
#
# $1: Prompt text
# $2 optional: variable to write result into
#
# One drawback is that this leaves the terminal's write position on the same
# line just after the y/n type by the user.
ask_user() {
  if (($# < 1 || 2 < $#)); then abort "Wrong usage"; fi
  declare _au_confirm_384734
  declare -n _au_res_1402420156="${2-"_au_confirm_384734"}"
  # test_blpi is the same as used by 'echou'. By now this colour means "text for
  # human at time of running", often of immediate importance.
  read -n 1 -rp "${text_blpi}${1}${text_normal} (y/N): " _au_confirm_384734
  if [[ "${_au_confirm_384734}" == [yY] ]]; then
    _au_res_1402420156="true"
  else
    _au_res_1402420156="false"
  fi
  if (($# == 1)); then
    printf -- "%s" "$_au_res_1402420156"
  else
    printf -- "%b" "\n"
  fi
}

# $1  (in)  Prompt text.
# ($2  (out)  Resut-variable, else result goes to stdout.)
# Out: "y" or "n"; to result-variable if $2 is provided, else to stdout.
boolean_prompt() {
  if (($# < 1 || 2 < $#)); then
    abort "Wrong usage"
  fi
  declare _bp_confirm_1748500628 # Avoid name conflicts
  declare -n _bp_res_1402420156="${2-"_bp_confirm_1748500628"}"
  read -rp "$1 [y/N]: " _bp_confirm_1748500628
  if [[ "${_bp_confirm_1748500628^^}" == "Y" || "${_bp_confirm_1748500628^^}" == "YES" ]]; then
    _bp_res_1402420156="y"
  else
    _bp_res_1402420156="n"
  fi
  if (($# == 1)); then
    printf -- "%s" "$_bp_res_1402420156"
  fi
}

# Funny automation halper: Prints steps to be done and waits for confirmation.
# If the user declines, returns 1.
#  - $1:  first message
#  - $2:  second message
#  - ...
manually() {
  declare userAnswer=""
  declare -i i=0
  while (($# > 0)); do
    echoT "$((++i))." "$1"
    ask_user "Done?" userAnswer
    if [[ "$userAnswer" != "true" ]]; then
      echow "User aborted process"
      return 1
    fi
    shift
  done
  echok "${i} manual steps"
}
