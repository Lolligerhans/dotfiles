#!/usr/bin/env bash

# version 0.0.0

# shellcheck disable=2015,2004

if [[ -v _sourced_files["version"] ]]; then
  return 0
fi
_sourced_files["version"]=""

# ❗ We need to source some files to enable versioning in the first place.
#    These (and their recursive dependencies) are veryfied here, at the end of
#    this file.
source "$dotfiles/scripts/utils.sh"
source "$dotfiles/scripts/userinteracts.sh"

# TODO Document usage

################################################################################
# Config
################################################################################

declare -gri _debug_version=0
declare -gr _version_log_loads=1
declare -gr _version_random_pass=0 # 0=no, 1=½, 7=⅛, 15=⅟16

declare -gr version_line_regex='^# version (.*)$'

# RegEx Taken from semver.org v2.0.0
declare -gr semver_regex='^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$'
declare -gra version_colour=(
  "$text_blr"
  "$text_blo"
  "$text_bly"
  "$text_lightgreen"
  "$text_lightblue"
)

# Test while sourcing. If you change it later it's on you.
if [[ "$(shopt -p extglob)" != "shopt -s extglob" ]]; then
  errchoe "${BASH_SOURCE[0]} requires extglob to tell numeric from alphanum identifiers"
  abort "Insisting on 'shopt -s extglob'"
fi

################################################################################
# API (end with _version)
################################################################################

# ℹ SemVar_group=(major minor patch prerelease buildmetadata)

satisfy_version() {
  ((_debug_version)) && errchod "$(print_values "${FUNCNAME[0]}" "$@")" || :
  declare -r file="${1:?"${FUNCNAME[0]}: missing file as first argument"}"
  declare expected_string="${2:-}"

  # 🎲 For now we leave versioning always on, but with surprise factor.
  if (($RANDOM % (_version_random_pass + 1) != 0)); then
    return 0
  fi

  #errchol "Satisfying $1 🅅 $2 from ${BASH_SOURCE[1]}";

  if [[ -z "$expected_string" ]]; then
    augment_version expected_string "$file"
    # Continuing. This also allows to verify the newly chosen version string.
    ((_debug_version)) && errchol "augment_version returned ➜ $expected_string"
  fi

  version_check "$file" "$expected_string"
}

# $1  file
# ($2  version string)
load_version() {
  ((_debug_version)) && errchod "$(print_values "${FUNCNAME[0]}" "$@")" || :
  if (($# < 1 || 2 < $#)); then
    abort "Expected 1 or 2 arguments, got $#"
  fi
  #errchol "Loading $1 🅅 $2 from ${BASH_SOURCE[1]}";
  if satisfy_version "$@"; then
    # shellcheck disable=SC1090
    source "$1"
  fi
}

################################################################################
# Helpers (start with version_)
################################################################################

# ❗ Only print to stderr to allow print_commands to work normally

version_check() {
  ((_debug_version)) && errchod "$(print_values "${FUNCNAME[0]} →" "$@")" || :
  # Read runscript config if there is one
  if [[ -v _run_config["log_loads"] ]]; then
    declare -ir log_loads="${_run_config["log_loads"]}"
  else
    declare -ir log_loads="$_version_log_loads"
    abort "${FUNCNAME[0]}: Defaults disabled (allow if you actually want them)"
  fi
  declare -r file="${1:?"${FUNCNAME[0]}: missing file as first argument"}"
  declare -r expected_string="${2:?"${FUNCNAME[0]}: missing version string as second argument"}"

  if [[ ! -v _run_config["versioning"] ]]; then
    # Use by default when wanting to use without config
    abort "${FUNCNAME[0]}: Insisting on availability of _run_config['versioning']"
  else
    if ((_run_config["versioning"] == 0)); then
      ((log_loads)) && errchos "${FUNCNAME[0]}: Versioning disabled for $text_dim$file$text_normal"
      return 0
    fi
  fi

  declare provided_string
  declare -i loaded=-1
  get_file_version_string provided_string loaded "$file"
  declare verified=""
  version_string_satisfied verified "$expected_string" "$provided_string"

  ((_debug_version)) && echoi "expected_string=${expected_string}" || :
  ((_debug_version)) && echoi "provided_string=${provided_string}" || :

  declare -i idx
  declare _lf_e _lf_p
  # TODO Re-use previous version objects
  if [[ $((log_loads)) || "$verified" == "false" ]]; then
    version_read "$expected_string" _lf_e
    version_read "$provided_string" _lf_p
  fi
  bash_source_foreign_idx "idx" # ❗ Index might be incorrect when loading from version.sh
  declare loaded_from_file="${BASH_SOURCE[idx]##*/}"
  declare loaded_from_func="${FUNCNAME[idx]:-<main?>}"
  declare loaded_from_line="${BASH_LINENO[idx - 1]}"

  if [[ "$verified" == "false" ]]; then
    # Print error message
    if [[ "$_lf_e" != "false" || "$_lf_p" != "false" ]]; then
      errchoe "🅅  ${text_user}${file##*/}${text_normal} $(version_print "_lf_e") ∉ $(version_print "_lf_p") ${loaded_from_file}${text_dim}:$loaded_from_line ${loaded_from_func}()${text_normal}"
      errchon "File ${text_user_hard}${BASH_SOURCE[idx]}${text_normal} line $text_user_hard${loaded_from_line}$text_normal requires different version of ${text_dim}${file}${text_normal}"
      show_file_lines "${BASH_SOURCE[idx]}" "$loaded_from_line"
      # TODO Add 'generate_stacktrace' function and use it here. This could also
      # help allowing us to notice when the displayed file is incorrect.
    else
      errchoe "expected $file 🅅  $expected_string -- $expected_string provided"
      errchof "Could not print coloured versions"
    fi

    abort "Require version satisfaction"
  fi

  if ((log_loads)); then
    declare _lf_e _lf_p
    version_read "$expected_string" _lf_e # TODO Use same variable as above?
    version_read "$provided_string" _lf_p
    declare colour
    if ((loaded)); then colour="${text_user_soft}"; else colour=""; fi
    # TODO This doesnt do exactly what we want but its a lot simpler
    # We stay in stderr to allow --autocomplete
    # FIXME It is time that autocomplete is implemented using env vars. This is
    # not great.
    # https://github.com/koalaman/shellcheck/issues/1538
    errchok "🅅  ${colour}${file##*/}${text_normal} $(version_print "_lf_e") ∈ $(version_print "_lf_p") ${loaded_from_file}${text_dim}:${loaded_from_line} ${loaded_from_func}()${text_normal}"
  fi

  return 0
}

# Read and verify semvar version string
# $1  (in)  version string in semvar format
# $2  (out) array name.
# Output: If valid, sets $2 to the version. Else sets out[0]=false.
#
# Test out != "false" to determine validity. Do NOT test out == "true".
version_read() {
  ((_debug_version)) && errchod "${FUNCNAME[0]} ←" "$@" || :
  if (($# < 2)); then
    abort "${FUNCNAME[0]}: expected 2 arguments, got $#"
  fi
  declare -r version_string="${1}"

  declare versioning_groups_string
  declare -i ret=""
  versioning_groups_string="$(
    trap - ERR
    set +e
    # "major=$1,minor=$2,patch=$3,prerelease=$4,buildmetadata=$5"
    perl -ne '(m/'"${semver_regex}"'/ && print "$1,$2,$3,$4,$5,") || exit 1;exit 0' <<<"$version_string"
  )" && ret=0 || ret=1

  ((_debug_version)) && errchod "${FUNCNAME[0]}: Perl return value: $ret" || :
  ((_debug_version)) && errchod "${FUNCNAME[0]}: versioning_groups_string=${versioning_groups_string//+($'\n')/ • }" || :

  declare -n _groups="${2:?"${FUNCNAME[0]}: missing group array"}"
  if ((ret == 0)); then
    IFS=',' read -ra _groups <<<"$versioning_groups_string"
  else
    _groups[0]="false" # Special format
  fi
  ((_debug_version)) && errchod "${FUNCNAME[0]} ➜ $(print_values "_groups" "${_groups[@]}")" || :
}

# $1  (out)  Nameref set to "true" if expected == provided, else  "false"
# $2  (in)  expected version groups
# $3  (in)  provided version groups
#
# TODO This function is kinda useless since its faster to just implement ad-hoc
version_equal() {
  ((_debug_version)) && errchod "${FUNCNAME[0]} ←" "$@" || :
  if (($# < 2)); then
    abort "${FUNCNAME[0]}: expected 2 arguments, got $#"
  fi

  declare -n _put_res="${1:?"${FUNCNAME[0]}: missing result variable"}"
  declare -rn _expected="${2:?"${FUNCNAME[0]}: missing expected version groups"}"
  declare -rn _provided="${3:?"${FUNCNAME[0]}: missing provided version groups"}"

  # Test whether all elements in both arrays are identical
  # TODO Better use {0:4} ?
  if [[ "${_expected[*]}" == "${_provided[*]}" ]]; then
    ((_debug_version)) && errchod "${FUNCNAME[0]}: ==" || :
    _put_res="true"
  else
    ((_debug_version)) && errchod "${FUNCNAME[0]}: !=" || :
    _put_res="false"
  fi
}

# Compare expected and provided semvarg group arrays.
# ❕ Bash compares [aA] < [bB] and a < A, so we use that. SemVer uses ASCII
#    values, which are different.
# $1  (out)  Nameref set to "true" if expected < provided, else  "false"
# $2  (in)  expected version groups
# $3  (in)  provided version groups
version_compare() {
  ((_debug_version)) && errchod "${FUNCNAME[0]}" "$@" || :
  declare -n _put_res="${1:?"${FUNCNAME[0]}: missing result variable"}"
  declare -rn _expected="${2:?"${FUNCNAME[0]}: missing expected version groups"}"
  declare -rn _provided="${3:?"${FUNCNAME[0]}: missing provided version groups"}"
  declare _res_tmp_buf=""
  ((_debug_version)) && errchod "${FUNCNAME[0]}: _expected=$(version_print "_expected")" || :
  ((_debug_version)) && errchod "${FUNCNAME[0]}: _provided=$(version_print "_provided")" || :
  declare -ri major_le="$((${_expected[0]} <= ${_provided[0]}))"
  declare -ri major_lt="$((${_expected[0]} < ${_provided[0]}))"
  declare -ri minor_le="$((${_expected[1]} <= ${_provided[1]}))"
  declare -ri minor_lt="$((${_expected[1]} < ${_provided[1]}))"
  declare -ri patch_le="$((${_expected[2]} <= ${_provided[2]}))"
  declare -ri patch_lt="$((${_expected[2]} < ${_provided[2]}))"

  ((_debug_version)) && errchod "${FUNCNAME[0]} mmajor_le=$major_le" || :

  # Exp    Prov
  if ((!major_le)); then
    _res_tmp_buf="false"
    ((_debug_version)) && errchod "${FUNCNAME[0]}: [test1]" || : # 1.x.x  0.x.x  ✖
  elif ((major_lt)); then
    _res_tmp_buf="true"
    ((_debug_version)) && errchod "${FUNCNAME[0]}: [test2]" || : # 1.x.x  2.x.x  ✔
  elif ((!minor_le)); then
    _res_tmp_buf="false"
    ((_debug_version)) && errchod "${FUNCNAME[0]}: [test3]" || : # 1.2.x  1.1.x  ✖
  elif ((minor_lt)); then
    _res_tmp_buf="true"
    ((_debug_version)) && errchod "${FUNCNAME[0]}: [test4]" || : # 1.2.x  1.3.x  ✔
  elif ((!patch_le)); then
    _res_tmp_buf="false"
    ((_debug_version)) && errchod "${FUNCNAME[0]}: [test5]" || : # 1.2.3  1.2.2  ✖
  elif ((patch_lt)); then
    _res_tmp_buf="true"
    ((_debug_version)) && errchod "${FUNCNAME[0]}: [test6]" || : # 1.2.3  1.2.4  ✔
  else                                                           # 1.2.3  1.2.3
    # Compare prerelease dot.separated.identifiers
    declare -a e_dsi p_dsi
    IFS="." read -ra e_dsi <<<"${_expected[3]}"
    IFS="." read -ra p_dsi <<<"${_provided[3]}"
    declare -i i=0
    declare -ri is_longer=$((${#e_dsi[@]} > ${#p_dsi[@]}))
    declare -ri min_len=$((is_longer ? ${#p_dsi[@]} : ${#e_dsi[@]}))

    # Special case: no prerelease for at least one of them
    if ((min_len == 0)); then
      # Prereleases are smaller than just normal versions
      #      _res_tmp_buf="$len_decider";
      if ((is_longer)); then
        ((_debug_version)) && errchod "${FUNCNAME[0]}: One is a normal version. Prerelease is smaller than normal version" || :
        _res_tmp_buf="true"
      else
        ((_debug_version)) && errchod "${FUNCNAME[0]}: One is a normal version. Normal release is not smaller than prerelease/normal version" || :
        _res_tmp_buf="false" # ❕ Includes equality when both are 'normal' versions
      fi

    # Both have some prerelease
    else

      # Loop to first different identifier
      if ((min_len == 10)); then abort "Sanity check: Assuming long pre-release version is faulty"; fi
      while ((i < min_len)); do
        if [[ "${e_dsi[i]}" != "${p_dsi[i]}" ]]; then
          break
        fi
        ((++i))
      done

      # Special case: No difference in identifier pairs. Shorter is smaller.
      if ((i == min_len)); then
        # Special case: No difference in existing identifiers
        if ((${#e_dsi[@]} < ${#p_dsi[@]})); then
          ((_debug_version)) && errchod "${FUNCNAME[0]}: When all previous match (>=1), Shorter prerelease is smaller" || :
          _res_tmp_buf="true"
        else
          ((_debug_version)) && errchod "${FUNCNAME[0]}: When all previous match (>=1), Equal length or longer prerelease is not smaller." || :
          _res_tmp_buf="false" # ❕ Includes equality when both prerelease versions are identical
        fi

      else
        # Distinguish numberic from alphanum idendifiers
        declare -i e_alpha p_alpha
        # No need to exclude leading 0 in this regex; assume correctness.
        if [[ "${e_dsi[i]}" == *([0-9]) ]]; then e_alpha=0; else e_alpha=1; fi
        if [[ "${p_dsi[i]}" == *([0-9]) ]]; then p_alpha=0; else p_alpha=1; fi

        # Lexicographic
        if ((e_alpha && p_alpha)); then
          if [[ "${e_dsi[i]}" < "${p_dsi[i]}" ]]; then
            _res_tmp_buf="true"
            ((_debug_version)) && errchod "${FUNCNAME[0]}: Alphanum prerelease is smaller" || :
          else
            _res_tmp_buf="false"
            ((_debug_version)) && errchod "${FUNCNAME[0]}: Alphanum prerelease is not smaller" || :
          fi

        # Numeric
        elif ((!e_alpha && !p_alpha)); then
          if ((${e_dsi[i]} < ${p_dsi[i]})); then
            _res_tmp_buf="true"
            ((_debug_version)) && errchod "${FUNCNAME[0]}: Numeric prerelease is smaller" || :
          else
            _res_tmp_buf="false"
            ((_debug_version)) && errchod "${FUNCNAME[0]}: Numeric prerelease is not smaller" || :
          fi

        # Numeric < alphanum
        elif ((e_num)); then
          _res_tmp_buf="true"
        else
          _res_tmp_buf="false"
        fi

      fi # Compare first non-identical identifier

    fi # Both have prerelease

  fi # Compare prerelease

  # Sanity check: make sure only true and false are outputted
  if [[ "$_res_tmp_buf" != "true" && "$_res_tmp_buf" != "false" ]]; then
    abort "${FUNCNAME[0]}: Result should be either true or false"
  fi
  ((_debug_version)) && errchod "${FUNCNAME[0]} ➜ $_res_tmp_buf" || :
  _put_res="$_res_tmp_buf"
}

# $1  (in)  expected string
# $2  (in)  provided string
# $3  (out) result ("true"/"false")
version_str_compare() {
  declare -r expected="${1:?"${FUNCNAME[0]}: missing expected string"}"
  declare -r provided="${2:?"${FUNCNAME[0]}: missing provided string"}"
  declare -nr result="${3:?"${FUNCNAME[0]}: missing result variable"}"

  # Special case: string equality is easy
  if [[ "$provided" == "$expected" ]]; then
    result="true"
    return 0
  fi

  # Generate version arrays
  declare -a provided expected
  version_read "$expected_string" expected
  version_read "$provided_string" provided
  echoi "Expected $(version_print "expected")"
  echoi "Provided $(version_print "provided")"
  if [[ "${expected[0]}" == "false" || "${provided[0]}" == "false" ]]; then
    abort "Could not parse for verification: expected=$text_dim$expected_string$text_normal, provided=$text_dim$provided_string$text_normal"
  fi

  # Compare as semvar
  declare res=""
  version_compare res "expected" "provided"
  result="$res"
  ((_debug_version)) && errchod "${FUNCNAME[0]}: Comparison result is $res" || :
}

# $1  (out) result ("true"/"false")
# $2  (in)  expected version string
# $3  (in)  provided version string
version_string_satisfied() {
  declare -n _vss_res="${1:?"${FUNCNAME[0]}: missing result variable"}"
  declare -r s_expected="${2:?"${FUNCNAME[0]}: missing expected version string"}"
  declare -r s_provided="${3:?"${FUNCNAME[0]}: missing provided version string"}"

  # Trivial case of equal strings
  if [[ "$s_expected" == "$s_provided" ]]; then
    _vss_res="true"
  else
    ((_debug_version)) && errchod "${FUNCNAME[0]}: not identical. doing full satisfaction check" || :
    declare -a _vss_e _vss_p
    version_read "$s_expected" _vss_e
    version_read "$s_provided" _vss_p
    version_satisfied _vss_res _vss_e _vss_p
  fi
  ((_debug_version)) && errchod "${FUNCNAME[0]} ➜ $_vss_res" || :
}

# Compute whether provided version setisfies expected version.
# Assumes maajor versions break, minor versions are backwards-compatible, patch
# versions are all-compatible and pre-release versions only satisfy versions
# that have normal versions lower (i.e., 2.1.0-whatever satisfies anything in
# 2.0.x, but the 2.1.x API is not yet stable, so it cant be considered
# satisfied).
#
# $1  (out) result ("true"/"false")
# $2  (in)  expected version groups
# $3  (in)  provided version groups
# ($4  (in)  predicate)
#
# If and only if major+minor+patch are inconclusive, predicate is used for
# arbitration.
version_satisfied() {
  ((_debug_version)) && errchod "${FUNCNAME[0]}" "$@" || :
  declare -n _output_="${1:?"${FUNCNAME[0]}: missing output variable"}"
  declare -rn _expected_="${2:?"${FUNCNAME[0]}: missing expected version groups"}"
  declare -rn _provided_="${3:?"${FUNCNAME[0]}: missing provided version groups"}"
  declare -r predicate="${4:-"version_compare"}"
  declare res=""
  ((_debug_version)) && errchod "${FUNCNAME[0]}: _expected_=$(version_print "_expected_")" || :
  ((_debug_version)) && errchod "${FUNCNAME[0]}: _provided_=$(version_print "_provided_")" || :

  # Sanity check: expected versions should be normal versions with no
  # pre-release.
  # ❗ When you want to remove this you must add that 1.2.3-alpha does not
  # satisfy 1.2.3.
  if [[ "${_expected_[3]}" != "" ]]; then
    errchon "${FUNCNAME[0]}: For development versions, use 'version_compare' instead."
    abort "${FUNCNAME[0]}: Expected version should not have pre-release"
  fi

  # Special case: equal versions are always satisfied
  declare equal=""
  version_equal equal _expected_ _provided_
  if [[ "$equal" == "true" ]]; then
    _output_="true"
    ((_debug_version)) && errchod "${FUNCNAME[0]}: Equal version always satisfy" || :
    return 0
  fi

  declare -ri major_eq=$((${_expected_[0]} == ${_provided_[0]}))
  declare -ri minor_le=$((${_expected_[1]} <= ${_provided_[1]}))
  declare -ri minor_lt=$((${_expected_[1]} < ${_provided_[1]}))
  declare -ir patch_le=$((${_expected_[2]} <= ${_provided_[2]}))
  declare -ir patch_lt=$((${_expected_[2]} < ${_provided_[2]}))
  declare -ir patch_gt=$((${_expected_[2]} > ${_provided_[2]}))

  # Exp    Prov
  if ((!major_eq)); then
    res="false" # 1.x.x  2.x.x  ✖
  elif ((!minor_le)); then
    res="false" # 1.2.x  1.1.x  ✖
  elif ((minor_lt)); then
    res="true" # 1.2.x  1.3.x  ✔
  #else                                   # 1.2.x  1.2.y
  elif ((patch_lt)); then
    res="true" # 1.2.3  1.2.4(-abc)  ✔ (Exp has no pre-release)
  # If there exists a smaller paatch version, that means they are both greater
  # or equal to patch version 0.
  elif ((patch_gt)); then
    res="true" # 1.2.3  1.2.2

  # TODO Because we rely on patches to not change the API, we cannot
  #      meaningfully 'expect' a non-zero patch version. While we allow
  #      specifying them, the behavious stays the same.
  #      In the fure, we can allow meaningfull patch-versions in the 'expected'
  #      version to express the intend of using bug fixes (or, say,
  #      "unobservable" speedups that do not alter the API).

  # ❕ Patch-version of 'expected' version is meaningless at the moment, except
  #    for allowing to more easily determine satisfaction by having a lower
  #    patch version. A higher 'expected' patch version IS NOT ENFORCED.
  # From here on, we can leverage assert(expected.isNormalVersion()) to deduce
  # that only provided possibly has a pre-release.
  # 1. If (the equal) patch version > 0, a provided version with pre-release
  #    still satisfies.
  # 2. If (the equal) patch version == 0, a provided version with pre-release
  #    DOES NOT satisfy.
  # ❕ If we were to allow a version without pre-release as expectation, then we
  # may need to take special care to handle the potential change of API with
  # pre-releases.
  else                                 # 1.2.3  1.2.3
    if ((${_provided_[2]} == 0)); then # equal to expected[2] at this point
      if [[ -z "${_provided_[3]}" ]]; then
        ((_debug_version)) && errchod "${FUNCNAME[0]} ➜ ✔ patch version == 0. No pre-release, so we satisfy. expected should not be pre-release either." || :
        res="true" # Same version except build possibly
      else
        ((_debug_version)) && errchod "${FUNCNAME[0]} ➜ ✖ patch version == 0. Pre-release does not satisfy equal normal version!" || :
        res="false" # Same patch but provided pre-release
      fi
    else # > 0 implicitly by previous if-elses
      ((_debug_version)) && errchod "${FUNCNAME[0]} ➜ ✔ patch version > 0 implied. Should be safe regardless of patch and pre-release" || :
      res="true"
    fi

    # FIXME I dont think this would be correct, even if pre-releases were
    # allowed, because a smaller pre-release is still usntablel along that
    # pre-release dimension. ❗
    #((_debug_version)) && errchod "${FUNCNAME[0]}: major-minor didnt resolve. Checking predicate '$predicate'" || :;
    #"$predicate" res "_expected_" "_provided_";
    #((_debug_version)) && errchod "${FUNCNAME[0]}: Predicate result is $res" || :;
  fi

  ((_debug_version)) && errchod "${FUNCNAME[0]}: expected version $(version_print "_expected_") $([[ "$res" == "true" ]] && echo -n "satisfies ✔" || echo -n "violates ✖") provided version $(version_print "_provided_")" || :

  _output_="$res"
}

# Colourized version print. Resets ANSII color codes.
# $1  (in)  semvar group array
version_print() {
  declare -nr _pr1ntgrp_="${1:?"${FUNCNAME[0]}: missing group array"}"
  declare -r a="$text_blc"
  declare -r b="$text_normal"
  if ((${#_pr1ntgrp_[3]} != 0)); then
    declare -r pre="$a-$b"
  else
    declare -r pre=""
  fi
  if ((${#_pr1ntgrp_[4]} != 0)); then
    declare -r build="$a+$b"
  else
    declare -r build=""
  fi
  printf -- "%s$a.$b%s$a.$b%s$pre%s$build%s" \
    "${version_colour[0]}${_pr1ntgrp_[0]}${text_normal}" \
    "${version_colour[1]}${_pr1ntgrp_[1]}${text_normal}" \
    "${version_colour[2]}${_pr1ntgrp_[2]}${text_normal}" \
    "${version_colour[3]}${_pr1ntgrp_[3]}${text_normal}" \
    "${version_colour[4]}${_pr1ntgrp_[4]}${text_normal}" \
    ;
}

# Global cache variable for files' version strings.
# ❕ This means that this is only suitable for frequently-restarted processes.
# TODO Cache version strings in a file?
declare -gA _version_string_cache
((_debug_version)) && errchod "$text_cyan Loading version.sh, i.e., resetting the string cache$text_normal" || :

# $1  (out)  result (version string)
# $2  (out)  1 if loaded, 0 if cached
# $3  (in)   filename
get_file_version_string() {
  declare -n _gfvs_res="${1:?"${FUNCNAME[0]}: missing result variable"}"
  declare -n _gfvs_res_loaded="${2:?"${FUNCNAME[0]}: missing loaded variable"}"
  declare -r file="${3:?"${FUNCNAME[0]}: missing file"}"
  if [[ -v _version_string_cache["$file"] ]]; then
    _gfvs_res="${_version_string_cache["$file"]}"
    _gfvs_res_loaded=0
    ((_debug_version)) && errchod "$text_green${FUNCNAME[0]}: Loaded cached version string ${_gfvs_res} for $text_dim$file$text_normal" || :
  else
    read_file_version_string "_gfvs_res" "$file"
    _gfvs_res_loaded=1
    _version_string_cache["$file"]="${_gfvs_res}"
    ((_debug_version)) && errchod "$text_red${FUNCNAME[0]}: Cached version string ${_gfvs_res} for $text_dim$file$text_normal" || :
  fi
}

################################################################################
# Atomics
################################################################################

# $1  (out)  result (version string)
read_file_version_string() {
  declare -n _rfvs_res="${1:?"${FUNCNAME[0]}: missing result variable"}"
  declare -r file="${2:?"${FUNCNAME[0]}: missing file"}"
  _rfvs_res="$(sed -nE -e '1,5s/'"${version_line_regex}"'/\1/p' "$file")"
  if [[ -z "$_gfvs_res" ]]; then
    errchoe "Could not find version line in $text_dim$file$text_normal"
    abort "Require version line"
  fi
}

# Function that automatically appends the version of the requested file to the command envoking it, if not supplied with a version in the call itself.
# $1  (out)  resulting version string
# $2  (in)  versioned_file
# $3  (in)  source_file
# $4  (in)  source_line
function augment_version() {
  declare -n _av__res="${1:?"${FUNCNAME[0]}: missing result variable"}"
  declare -r versioned_file="${2:?"${FUNCNAME[0]}: missing versioned file"}"

  # Find first source outside of version.sh
  declare -i file_idx=0
  bash_source_foreign_idx "file_idx"

  if ((_debug_version)); then
    errchod "Index found using foreign idx: $file_idx"
    errchod "Call stack:"
    declare -i i=0
    while caller $i; do ((++i)); done
    errchod "$(print_values BASH_SOURCE "${BASH_SOURCE[@]}")"
    errchod "$(print_values FUNCNAME "${FUNCNAME[@]}")"
    errchod "$(print_values BASH_LINENO "${BASH_LINENO[@]}")"
  fi

  if ((file_idx == ${#BASH_SOURCE[@]})); then
    echow "${FUNCNAME[0]}: Failed to identify version augmentation target"
    # TODO return 0 and leave it at warning?
    return 1
  fi
  declare -r source_file="${BASH_SOURCE[file_idx]}"
  declare -ri source_line="${BASH_LINENO[file_idx - 1]}"

  declare version_string decoy
  get_file_version_string "version_string" decoy "$versioned_file"
  _av__res="$version_string" # Inform called about version we decided to use
  # A thorough test is not needed since is is verified next call.
  if [[ "$version_string" != +([[:alnum:]-.*+]) ]]; then
    errchoe "Cannot augment $text_dim$source_file:$source_line$text_normal with malformed version string $text_user$version_string$text_normal"
    abort "Use a valid version string"
  fi

  declare -r regex='^(load|satisfy)_version "([^"]*)";$'

  # Add version to call using the sed program with appropriate substitution
  # command.
  errchow "In $text_dim$source_file:$source_line ${FUNCNAME[file_idx]}()$text_normal missing version string $text_user$version_string$text_normal for $text_user_soft$versioned_file$text_normal"
  show_file_lines "$source_file" "$source_line" ||
    errchow "${FUNCNAME[0]}: Failed to show relevant lines"
  errchou "Files should generally be versioned."

  if [[ "$(ask_user "Add current version $version_string automatically?")" == "true" ]]; then
    # FIXME Verify replacement and initial format
    if sed --follow-symlinks -i -Ee "$((source_line))"'s/^(load|satisfy)_version "([^"]*)";$/\1_version "\2" "'"$version_string"'";/' "$source_file"; then
      errchon "To $text_dim$source_file:$source_line ${FUNCNAME[file_idx]}()$text_normal added version string $text_user$version_string$text_normal for $text_user_soft$versioned_file$text_normal"
    else
      errchof "We have no backup for this operation"
      errchof "Check if your file is still intact"
      abort "TODO implement case when augmentation fails"
    fi

  else
    errchos "Leaving $versioned_file version unconfigured in $text_user_soft$source_file:$source_line$text_normal ${FUNCNAME[file_idx]}()"
  fi
}

show_file_lines() {
  declare -r file="${1:?"${FUNCNAME[0]}: missing file"}"
  declare -r line="${2:?"${FUNCNAME[0]}: missing line"}"
  batcat -l bash --highlight-line="$((line))" --line-range "$((line - 3 < 0 ? 0 : line - 3)):$((line + 3))" "$file" ||
    { sed -ne "$((line - 3 < 0 ? 0 : line - 3)),$((line + 3))p" "$file"; } ||
    {
      errchoe "${FUNCNAME[0]}: Failed to show $file:$line"
      return 1
    }
}

################################################################################
# Warn if versioning is not available
################################################################################

#((_version_log_loads)) && {
# Since this is is printed no matter the command we stick to stderr
#  errchoi "Versioning available";
#}
if ((_run_config["versioning"] == 0)); then
  errchow "Boilerplate: Versions not checked"
fi

################################################################################
# "Includes" (need be included raw, but still ensure versions after the fact)
################################################################################

# ❕ These are the recursive dependencies of version.sh, which themselves cannot
#    use the version helpers. The alternative would be to collect version
#    requireements in a variable before version.sh was loded, and check them
#    afterwards.

# We cannot put this in top since we are defining 'load_version' just now
# Ensuring version even if included already
satisfy_version "$dotfiles/scripts/version.sh" 0.0.0 # Now we eating our own tail a bit
satisfy_version "$dotfiles/scripts/termcap.sh" 0.0.0
satisfy_version "$dotfiles/scripts/userinteracts.sh" 0.0.0
satisfy_version "$dotfiles/scripts/utils.sh" 0.0.0
