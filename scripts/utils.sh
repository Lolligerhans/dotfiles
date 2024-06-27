#!/usr/bin/env bash

# version 0.0.0

if [[ -v _sourced_files["dot_utils"] ]]; then
  return 0;
fi
_sourced_files["dot_utils"]="";

# We specificall do NOT provided a version since this is loaded before
# versioning.

# Used by versioning so cannot use version in advance.
# TODO Move some functions into versioned files
# TODO Remove the versioning from termcap.sh since we cant use is properly (?)
source "$dotfiles/scripts/termcap.sh";

# Outputs lowest (closes) BASH_SOURCE entry index NOT identical to the one of
# the caller to this function. If none is found, output -1.
# ($1  (out)  If given, variable to write result to instead of stdout)
bash_source_foreign_idx()
{
  declare -i bsfi_index;
  declare -n _bsfi_asdoaojasjd_="${1:-"bsfi_index"}"; # Avoid name collisions
  _bsfi_asdoaojasjd_=-1;
  for (( bsfi_index=2; bsfi_index < ${#BASH_SOURCE[@]}; ++bsfi_index )); do
#    errchod "$FUNCNAME ➜ ${BASH_SOURCE[bsfi_index]} <=> ${BASH_SOURCE[bsfi_index - 1]}";
    # TODO Possible -ef is better but possibly also slower
    if [[ "${BASH_SOURCE[bsfi_index]}" != "${BASH_SOURCE[bsfi_index - 1]}" ]]; then
      _bsfi_asdoaojasjd_="$((bsfi_index - 1))"; # From caller perspective it's 1 less
      break;
    fi
  done
  if (( $# == 0 )); then
    printf "%s" "$((_bsfi_asdoaojasjd_))";
  fi
}

common_prefix()
{
  # https://stackoverflow.com/a/17475354
  printf "%s\n" "$@" | sed -e '$!{N;s/^\(.*\).*\n\1.*$/\1\n\1/;D;}';
}

# $1:      should
# $2:      is
# Return:  0 if 'should' <= 'is' using sort -V, else 1
# TODO Currently not in use.
# TODO Confusing name: smae name as another command + confused with verion.sh
#      functions
test_version()
{
  if (("$#" != 2)); then abort "$FUNCNAME: Wrong usage:" "$@"; fi
#  set_args "--should= --is=" "$@";
#  eval "$get_args;
  declare -r should="$1";
  declare -r is="$2";
  declare -r smallest="$(sort -Vs <<< "$is"$'\n'"$should" | head -1)";
  if [[ "$smallest" == "$should" ]]; then
    return 0;
  else
    errchoe "Version too small: should $text_dim$should$text_normal, is $text_dim$is$text_normal";
    return 1;
  fi
}

# date -Isecodns with replace ":" with "-" to use in filenames.
# Character : works in normal directories, but not in /media on my stick.
date_nocolon()
{
  printf "%s" "$(date -Iseconds | tr ':' '-')";
}

# $1 Name
# ${@:2} Values
#
# Resets the colour *after* printing the name
print_values()
{
#  set -eEuo pipefail;
  declare -r name="${1:?print_values: Missing name}";
  declare listed="";
  printf -v listed "$text_dim%s$text_normal, " "${@:2}";
  printf "%s${text_normal}[$(($#-1))]=(%s)" "$name" "${listed}";
}

# $1  Name
# $2  Value colour (may be "")
# $3  Neutral colour (may be "")
# ${@:4}  Values
#
# Resets the colour *after* printing the name
print_values_decorate()
{
#  set -eEuo pipefail;
  declare -r name="${1}";
  declare -r colour="${text_normal}${2:-"$text_user"}";
  declare -r neutral="${text_normal}${3:-"$text_normal"}";
  declare listed="";
  if (($# > 3)); then
    printf -v listed "$colour%s$neutral, " "${@:4}";
  else
    listed="";
  fi
  printf "%s${neutral}[$(( $# >= 3 ? $#-3 : 0))]=(%s)${text_normal}" "$name" "${listed}";
}

# $1: Name of array
# Output: String representation of array (without newline)
print_array()
{
  declare -n _pa__dajihiahnjdsns_="${1}"; # Just a super rare name
  print_values "$1" "${_pa__dajihiahnjdsns_[@]}";
  return 0;
}

# Remove ANSI escape sequences from $1
remove_ansi_escape()
{
  if ! shopt -p extglob > /dev/null; then
    abort "extglob required";
  fi
  printf "%s" "${1//$'\e['*([0-9;])m/}";
  # Alternative:
  #sed -e 's/\x1b\[[0-9;]*m//g' <<< "$1";
  return 0;
}

# Symlink a dotfile stored in the dotfiles directory to some location
function abort()
{
  declare -r msg="${1:-}";
  declare -r fail="${2:-exit}"; # Pass $2=return instead to trigger error handling
  declare -ri code="${3:-1}";

  if (( code == 0 )); then abort "Must abort with nonzero code"; fi
  errchow "$text_blo$code $text_dim←$text_normal ${text_orange}${FUNCNAME[1]}()$text_normal »$msg«";
  if [[ "$fail" == "exit" ]]; then
    exit "$code"; # Exit to fail semi silently
  else
    if [[ "$-" != *e* ]]; then
      errchoe "$FUNCNAME: Requires errexit";
      errchow "$FUNCNAME: Replacing return with exit";
      exit "$code";
    fi
    return "$code"; # Return nonzero code to trigger error trace
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
  echod() {     echo "[${text_italic}DEBUG${text_normal}]" "$@"; };
  echoe() {     echo "${text_br}[${text_blr}ERROR${text_br}]$text_normal" "$@"; };
    # shellcheck disable=SC2145
  echof() {     echo "${text_bold}[${text_BI}FIXME${text_normal}${text_bold}]$text_normal $text_standout$@$text_normal"; };
    # shellcheck disable=SC2145
  echoh() {     echo "${text_bold}[${text_BI}HINT${text_normal}${text_bold}]$text_normal $text_standout$@$text_normal"; } # TODO What colour?
  echoi() {     echo "${text_by}[${text_bly}INFO${text_by}]$text_normal" "$@"; };
  echok() {     echo "${text_bg}[${text_blg}OK${text_bg}]$text_normal" "$@"; };
  echol() {     echo "${text_bb}[${text_blb}LOG${text_bb}]$text_normal" "$@"; };
  echon() {     echo "${text_bp}[${text_blp}NOTE${text_bp}]$text_normal" "$@"; };
  echos() {     echo "${text_bc}[${text_blc}SKIP${text_bc}]$text_normal" "$@"; };
  echot() {     echo "${text_bold}[${text_standout}TODO${text_normal}${text_bold}]$text_normal" "$@"; };
    # shellcheck disable=SC2145
  echou() {     echo "${text_bpi}[${text_blpi}☻ ${text_bpi}]$text_blpi" "$@$text_normal"; };
  echow() {     echo "${text_bo}[${text_blo}WARNING${text_bo}]$text_normal" "$@"; };

errcho () { >&2 echo  "$@"; }
errchod() { >&2 echod "$@"; };
errchoe() { >&2 echoe "$@"; };
errchof() { >&2 echof "$@"; };
errchoi() { >&2 echoi "$@"; };
errchok() { >&2 echok "$@"; };
errchol() { >&2 echol "$@"; };
errchon() { >&2 echon "$@"; };
errchos() { >&2 echos "$@"; };
errchot() { >&2 echot "$@"; };
errchou() { >&2 echou "$@"; };
errchow() { >&2 echow "$@"; };

function print_and_execute()
{
  if [ "$#" -lt 1 ]; then
    echo "Wrong usage";
    return 1;
  fi

  echol "Executing: $(print_values "command" "$@")";
  "${@}";

  return "$?";
}

# TODO Replace gradually by version below returning ints

# $1: repetition count
# ($2: character)
# ($3: output variable name)
# If $3 is given, writes variable. Else writes to stdout.
repeat_string()
{
  declare -i count="${1}";
  declare str="${2:-"="}";

  ## NEW VERSION (good)
  declare res;
  printf -v res "%${count}s";
  res="${res// /"$str"}";
  if (($# == 3)); then
    declare -n _repeat_string__ref="${3}";
    printf -v _repeat_string__ref "%s" "$res";
  else
    printf "%s" "${res}";
  fi
  return 0;
}
