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

# 1-tap version of boolean_prompt. Prints "true" or "false".
# if $2 is given, output is assigned to it by reference.
ask_user()
{
  if (( $# < 1 || 2 < $# )); then abort "Wrong usage"; fi
  declare _au_confirm_384734;
  declare -n _au_res_1402420156="${2-"_au_confirm_384734"}";
  errchof "We recently changed the return of ask_user!";
  read -n 1 -rp "$1 [y/N]: " _au_confirm_384734;
  printf -- "\n"; # Because we read only 1 character
  if [[ "${_au_confirm_384734}" == [yY] ]]; then
    _au_res_1402420156="true";
  else
    _au_res_1402420156="false";
  fi
  if (($# == 1)); then
    printf -- "%s" "$_au_res_1402420156";
  fi
}

# $1  (in)  Prompt text.
# ($2  (out)  Resut-variable, else result goes to stdout.)
# Out: "y" or "n"; to result-variable if $2 is provided, else to stdout.
boolean_prompt()
{
  if (( $# < 1 || 2 < $# )); then
    abort "Wrong usage";
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
    printf -- "%s" "$_bp_res_1402420156";
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
