#!/usr/bin/env bash

# version 0.0.0

if [[ -v _sourced_files["dot_utils"] ]]; then
  return 0
fi
_sourced_files["dot_utils"]=""

# Used by versioning so cannot use version in advance.
source "$dotfiles/scripts/termcap.sh"

# TODO: Move some functions into versioned files

# Outputs lowest (closest) BASH_SOURCE entry index NOT identical to the one of
# the caller to this function. If none is found, output -1.
# ($1  (out)  If given, variable to write result to instead of stdout)
bash_source_foreign_idx() {
  declare -i bsfi_index
  declare -n _bsfi_asdoaojasjd_="${1:-"bsfi_index"}" # Avoid name collisions
  _bsfi_asdoaojasjd_=-1
  for ((bsfi_index = 2; bsfi_index < ${#BASH_SOURCE[@]}; ++bsfi_index)); do
    if [[ "${BASH_SOURCE[bsfi_index]}" != "${BASH_SOURCE[bsfi_index - 1]}" ]]; then
      _bsfi_asdoaojasjd_="$((bsfi_index - 1))" # From caller perspective it's 1 less
      break
    fi
  done
  if (($# == 0)); then
    printf "%s" "$((_bsfi_asdoaojasjd_))"
  fi
}

# Outputs the date in a filename friendly format, replacing ":" with "-". The
# colon is not available on some filesystems. The output pattern-matches with
# a length of 25:
#     +([[:digit:]T+-])
# Example:
#     2024-12-31T23-59-59+11-59
# Interface:
#   - stdout: output
date_nocolon() {
  declare -r data_str
  date_str="$(command date -Iseconds)"
  printf -- "%s" "${date_str//":"/"-"}"
}

# $1 Name
# ${@:2} Values
#
# Resets the colour *after* printing the name
print_values() {
  #  set -eEuo pipefail
  declare -r name="${1:?print_values: Missing name}"
  declare listed=""
  printf -v listed "$text_dim%s$text_normal, " "${@:2}"
  printf "%s${text_normal}[$(($# - 1))]=(%s)" "$name" "${listed}"
}

# $1  Name
# $2  Value colour (may be "")
# $3  Operator colour (may be "")
# ${@:4}  Values
#
# Resets the colour *after* printing the name
print_values_decorate() {
  #  set -eEuo pipefail
  declare -r name="${1}"
  declare -r value="${text_normal}${2:-"$text_normal"}"
  declare -r operator="${text_normal}${3:-"$text_user_soft"}"
  declare listed=""
  if (($# > 3)); then
    printf -v listed "$value%s$operator, " "${@:4}"
  else
    listed=""
  fi
  printf "%s${operator}[${value}$(($# >= 3 ? $# - 3 : 0))${operator}]=(%s)${text_normal}" "$name" "${listed}"
}

# $1: Name of array
# Output: String representation of array (without newline)
print_array() {
  declare -n _pa__dajihiahnjdsns_="${1}" # Just a super rare name
  print_values "$1" "${_pa__dajihiahnjdsns_[@]}"
  return 0
}

# Symlink a dotfile stored in the dotfiles directory to some location
function abort() {
  declare -r msg="${1:-}"
  declare -r fail="${2:-exit}" # Pass $2=return instead to trigger error handling
  declare -ri code="${3:-1}"

  if ((code == 0)); then abort "Must abort with nonzero code"; fi
  errchow "${text_orange}${text_dim}${BASH_SOURCE[1]}:${BASH_LINENO[1]} ${text_normal}${text_blo}${FUNCNAME[1]}() → ${code} »${text_normal}${msg}${text_blo}«${text_normal}"
  if [[ "$fail" == "exit" ]]; then
    exit "$code" # Exit to fail semi silently
  else
    if [[ "$-" != *e* ]]; then
      errchoe "${FUNCNAME[0]}: Requires errexit"
      errchow "${FUNCNAME[0]}: Replacing return with exit"
      exit "$code"
    fi
    return "$code" # Return nonzero code to trigger error trace
  fi
}

# errcho<?>: Same as echo<?> but on stderr. We mostly use stderr, unless output
#            is the intended result of a function (rather than something being
#            done).
# echo<e> (error): Notify about an error. Could be misuse, failure, ...
# echo<d> (debug): Log debug message that is not needed if the code works correctly
# echo<f> (fixme): Print message for the developer to act on
# echo<f> (hint): Print message for the user. Like a warning, but for expected
#                 behaviour.
# echo<i> (info): Show contextualizing information to inform the user, like data
# echo<k> (ok): Log AFTER something was done
# echo<l> (log): Log code path, before or after things happen
# echo<n> (note): Multi-purpose. Often used to add relevant information to other
#                 special echo functions.
# echo<s> (skip): Log AFTER not doing something
# echo<t> (todo): Print a message for the user to act on
# echo<w> (warning): Notify user of suspicious behaviour/values or events that
#                    may surprise them (even if the code works as intended)
#                    echoi (info): Log information from the code context that is
#                    relevant, like variable contents, decisions, ...
# TODO Use printf, probably faster
# FIXME: Cannot print "-e" because echo has no -- option
echod() { echo "[${text_italic}DEBUG${text_normal}]" "$@"; }
echoe() { echo "${text_br}[${text_blr}ERROR${text_br}]$text_normal" "$@"; }
# shellcheck disable=SC2145
echof() { echo "${text_bold}[${text_BI}FIXME${text_normal}${text_bold}]$text_normal $text_standout$@$text_normal"; }
# shellcheck disable=SC2145
echoh() { echo "${text_bold}[${text_BI}HINT${text_normal}${text_bold}]$text_normal $text_standout$@$text_normal"; } # TODO What colour?
echoi() { echo "${text_by}[${text_bly}INFO${text_by}]$text_normal" "$@"; }
echok() { echo "${text_bg}[${text_blg}OK${text_bg}]$text_normal" "$@"; }
echol() { echo "${text_bb}[${text_blb}LOG${text_bb}]$text_normal" "$@"; }
echon() { echo "${text_bp}[${text_blp}NOTE${text_bp}]$text_normal" "$@"; }
echos() { echo "${text_bc}[${text_blc}SKIP${text_bc}]$text_normal" "$@"; }
echot() { echo "${text_bold}[${text_standout}TODO${text_normal}${text_bold}]$text_normal" "$@"; }
# shellcheck disable=SC2145
echou() { echo "${text_bpi}[${text_blpi}☻ ${text_bpi}]$text_blpi" "$@$text_normal"; }
echow() { echo "${text_bo}[${text_blo}WARNING${text_bo}]$text_normal" "$@"; }

errcho() { >&2 echo "$@"; }
errchod() { >&2 echod "$@"; }
errchoe() { >&2 echoe "$@"; }
errchof() { >&2 echof "$@"; }
errchoi() { >&2 echoi "$@"; }
errchok() { >&2 echok "$@"; }
errchol() { >&2 echol "$@"; }
errchon() { >&2 echon "$@"; }
errchos() { >&2 echos "$@"; }
errchot() { >&2 echot "$@"; }
errchou() { >&2 echou "$@"; }
errchow() { >&2 echow "$@"; }

# Prefix time and line and echo the rest using $1
# Local helper, do not use elsewhere.
_echoInfo() {
  (($# < 1)) && return 1 # Would be logic error
  # The FUNCNAME and BASH_LINENO are essentially offset by two levels, so that
  # the caller of, e.g., 'echoL' gets referenced, not the '_echoInfo' or 'echoL'
  # contexts themselves.
  # This means it is typically pointless to call this function elsewhere.
  "$1" "${text_brightblack}$(date -Iseconds) ${text_lightblue}${FUNCNAME[2]} ${text_dim}${BASH_LINENO[1]}${text_normal}" "${@:2}"
}
echoK() { _echoInfo echok "$@"; }
echoL() { _echoInfo echol "$@"; }
echoE() { _echoInfo echoe "$@"; }
echoT() { _echoInfo echot "$@"; }

function print_and_execute() {
  if [ "$#" -lt 1 ]; then
    echo "Wrong usage"
    return 1
  fi

  echol "Executing: $(print_values "command" "$@")"
  "${@}"

  return "$?"
}
