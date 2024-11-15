#!/usr/bin/env bash

# version 0.0.0

# These functions belong to commands_test.sh but we store them here because
# they are so plentyful.

# Source scripts/version.sh in the file you are sourcing this

# Used from working dir ~/dotfiles/
#load_version "$dotfiles/scripts/assert.sh" 0.0.0;

test_version_sensitivity() {
  #  echol "Testing version sensitivity";
  declare -r legal_versions=(
    "0.0.0"
    "2985238.42.12345632"

    "1.2.3-whatever"
    "1.2.3-0whatever"
    "1.2.3-0.0whatever"
    "1.2.3-0.0whatever.42.01b"

    "1.2.3-whatever+whatever"
    "1.2.3-0whatever+0whatever"
    "1.2.3-0.0whatever+0.0whatever"
    "1.2.3-0.0whatever.1.01b+0.0whatever.1.01b"

    "1.2.3+ignored"
    "1.2.3-5.13.5.giggedy.gr.v.3.54"
    "1.2.3+fgew5.L.55Z.0R.EF.5425"
  )
  declare inp
  declare -a out
  for inp in "${legal_versions[@]}"; do
    version_read "$inp" out
    >/dev/null assert_not_eq "${out[0]}" "false" "Version $inp is valid"
    >/dev/null assert_eq "${#out[@]}" "5" # "Version groups have 5 elements always";
  done
  echok "${FUNCNAME[0]}"
}

test_version_specificity() {
  #  echol "${FUNCNAME[0]}";
  declare -r illegal_versions=(
    "0.0.01"
    "1.2"
    "1"
    "1.2.3-not_this"
    "1.2.a"
    "a.2.3"
    "-nope"
    "+not"
    "-no+again"
    "1.2.3.not"
    "1.2.3+more_not"
    "1.2.3-why-is-this.illegal.0123.why"
    # Turns out starting 0 is ok for the last one
    #"1.2.3+05"
    "1.2.3-48..abc"
    "1.2.3-a..b"
    "1.2.3+a..b"
    ".2.3"
    ".1.2.3"
    "."
    "1.2.3-.4"
    "1.2.3-a,b"
    ""
    "done :)"
  )
  declare inp
  declare -a out=()
  for inp in "${illegal_versions[@]}"; do
    #    echoi "Testing $inp with length ${#inp}";
    version_read "$inp" out
    >/dev/null assert_eq "${out[0]}" "false" "Version '$inp' is invalid"
  done
  echok "${FUNCNAME[0]}"
}

test_version_compare() {
  #  echol "${FUNCNAME[0]}";
  declare -ra compares_true=(
    "0.0.0 ? 0.0.1"
    "1.2.3 ? 1.2.4"
    "1.2.3 ? 1.3.1"
    "1.2.3 ? 2.0.0"
    "1.2.3-99.99.99 ? 1.2.3"
    "1.2.3-42 ? 1.2.3-143"
    "1.2.3-no.42 ? 1.2.3-no.143"
    "1.2.3-no.42 ? 1.2.3-no.143"
    "1.2.3-n100 ? 1.2.3-n9"
    "1.2.3-n.3.0x100 ? 1.2.3-n.3.0x900"
    # ❕ Bash compares [aA] < [bB] and a < A, so we use that instead
    "1.2.3-a ? 1.2.3-A"
    "1.2.3-A ? 1.2.3-b"
    "1.2.3-a ? 1.2.3-B"
    "1.2.3-SHORT ? 1.2.3-SHORT.LONG"
    "1.2.3-- ? 1.2.3-A"
    "1.2.3-a ? 1.2.3-A+WHATEVER"
  )
  declare inp
  declare out
  declare -a _a _b
  for inp in "${compares_true[@]}"; do
    #echoi "Testing less-than: $inp";
    #version_read "${inp%%" ? "*}" _a | tee /tmp/test | read -n 3 a_ok;
    version_read "${inp%%" ? "*}" _a
    version_read "${inp##*" ? "}" _b
    #errchod "Comparing versions $(version_print "_a") < $(version_print "_b")";
    run_silent 1 assert_not_eq "${_a[0]}" "false" "Version must be read correctly"
    run_silent 1 assert_not_eq "${_b[0]}" "false" "Version must be read correctly"
    #echoi "Comparing: $(version_print "_a") < $(version_print "_b")";
    version_compare out "_a" "_b"
    assert_eq "$out" "true" "${inp/"?"/<}"
  done
  echok "${FUNCNAME[0]}"
}

# Test rejection of comparison function
test_version_compare_not() {
  # TODO
  :
}

test_version_satisfied() {
  #  echol "${FUNCNAME[0]}";
  declare -ra satisfies_true=(
    # exp    prov
    "1.2.3 ~ 1.2.3"
    "1.2.3 ~ 1.2.4"
    "1.2.3 ~ 1.2.0"
    "1.2.3 ~ 1.3.0"
    # We currently do not allow expecting pre-releases, since they have
    # unstable API anyway
    #"1.2.3-1 ~ 1.2.3-0"
  )

  declare inp
  declare out
  declare -a _expect _provide

  for inp in "${satisfies_true[@]}"; do
    version_read "${inp%%" ~ "*}" _expect
    version_read "${inp##*" ~ "}" _provide
    >/dev/null assert_not_eq "${_expect[0]}" "false"
    >/dev/null assert_not_eq "${_provide[0]}" "false"
    ((_debug_version)) && errchod "Testing $inp"
    ((_debug_version)) && errchod "Expect: $(version_print "_expect")"
    ((_debug_version)) && errchod "Provide: $(version_print "_provide")"
    version_satisfied out "_expect" "_provide"
    >/dev/null assert_eq "$out" "true" "Version satisfied by: $inp"
  done
  echok "${FUNCNAME[0]}"
}

# Test rejection of comparison function
test_version_satisfies_not() {
  # TODO
  echot "${FUNCNAME[0]}: Not implemented"
}
