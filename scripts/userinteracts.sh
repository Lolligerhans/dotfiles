#!/usr/bin/env bash
# ╭──────────────────────╮
# │ 🅅 ersion             │
# ╰──────────────────────╯
# version 0.0.0

# ╭──────────────────────╮
# │ ⚙ Boilerplate        │
# ╰──────────────────────╯
if [[ -v _sourced_files["userinteracts"] ]]; then
#  errchof "Not loading userinteracts";
  return 0;
fi
_sourced_files["userinteracts"]="";
#errchof "Loading userinteracts";
# ╭──────────────────────╮
# │ 🗀 Dependencies       │
# ╰──────────────────────╯
# shellcheck source=scripts/utils.sh
source "$dotfiles/scripts/utils.sh";

# ╭──────────────────────╮
# │ 🖩 Utils              │
# ╰──────────────────────╯

# 1-tap version of boolean_prompt
ask_user()
{
  if [[ "$#" != "1" ]]; then abort "Wrong usage"; fi
  declare confirm;
  read -rp "$1 [y/N]: " confirm;
  if [[ "$confirm" == [yY] ]]; then
    echo "1"; # true
  else
    echo "0"  # false
  fi
}

# $1  (in)  Prompt text.
# ($2  (out)  Resut-variable, else result goes to stdout.)
# Out: "y" or "n"; to result-variable if $2 is provided, else to stdout.
boolean_prompt()
{
  if (( $# < 1 || 2 < $# )); then
    abort "Wrong usage"
  fi
  declare _bp_confirm_1748500628; # Avoid name conflicts
  declare -n _bp_res_1402420156="${2-"_bp_confirm_1748500628"}";
  read -rp "$1 [y/N]: " _bp_confirm_1748500628;
  if [[ "${_bp_confirm_1748500628^^}" == "Y" || "${_bp_confirm_1748500628^^}" == "YES" ]]; then
    _bp_res_1402420156="y";
  else
    _bp_res_1402420156="n";
  fi
  if (($# == 1)); then
    printf "%s" "$_bp_res_1402420156";
  fi
}

# ❗ The problem with this is that you cannot tell if the answer was no or the
#    call just failed (i.e., when the function is not even available!).
# Use boolean_prompt instead.
test_user()
{
  if (($# != 1)); then abort "Wrong usage"; fi
  declare confirm;
  read -n1 -rep "$1 [y/N]: " confirm;
  if [[ "${confirm^}" == "Y" ]]; then
    return 0;
  else
    return 1;
  fi
}
