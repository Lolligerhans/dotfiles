#!/usr/bin/env bash
# ╭──────────────────────╮
# │ 🅅 ersion             │
# ╰──────────────────────╯
# version 0.0.0
# ╭──────────────────────╮
# │ 🛈 Info               │
# ╰──────────────────────╯
# TODO rename to test_functions.sh
# These commands belong to scripts/tests/run.sh. Do not source this file
# anywhere else - there are no include guards. The same goes for the other files
#     ./*_test.sh

# Functions that wrap easy functional tests are named test_*.
# Those that are not as easily automated are named command_*, to be called
# manually by the user of the test runscript.
# ╭──────────────────────╮
# │ 🗀 Dependencies       │
# ╰──────────────────────╯
load_version "$dotfiles/scripts/assert.sh" 0.0.0;

# Sourcing unit test routines that are too long to fit here
load_version setargs_test.sh 0.0.0;
load_version colour_test.sh 0.0.0;
load_version version_test.sh 0.0.0;
load_version userinteracts_test.sh 0.0.0;
load_version may_fail_test.sh 0.0.0;

# Ensuring version even if included already
load_version "$dotfiles/scripts/version.sh" 0.0.0;
load_version "$dotfiles/scripts/bash_meta.sh" "0.0.0";
#load_version "$dotfiles/scripts/boilerplate.sh" 0.0.0;
#load_version "$dotfiles/scripts/cache.sh" 0.0.0;
#load_version "$dotfiles/scripts/error_handling.sh" 0.0.0;
load_version "$dotfiles/scripts/fileinteracts.sh" 0.0.0;
#load_version "$dotfiles/scripts/git_utils.sh" 0.0.0;
#load_version "$dotfiles/scripts/progress_bar.sh" 0.0.0;
load_version "$dotfiles/scripts/setargs.sh" 0.0.0;
load_version "$dotfiles/scripts/termcap.sh" 0.0.0;
load_version "$dotfiles/scripts/utils.sh" 0.0.0;

# TODO Does not have much effect
# TODO Helper function that can silence and un-silence things.
# TODO Wrapper that calls tests silently, then echos ok, or repeats loudly if
#      they fail.
declare -gri loud_tests=0;

# ┌────────────────────────┐
# │ Commands               │
# └────────────────────────┘

#shellcheck disable=2116
test_bash_meta()
{
  declare out="";
  out="$(run_silent 1 'echo' 'hello silence')";
  assert_eq "$out" "" "No stdout when silenced";

  # shellcheck disable=SC2317
  _ctbm_out_err() { 1>&2 echo "hello silence"; }
  out="";
  out="$(2>&1 run_silent 1 '_ctbm_out_err')";
  assert_eq "$out" "hello silence" "Allowing stderr despite silence";
  unset _ctbm_out_err;

  out="";
  out="$(echo "still working")";
  assert_eq "$out" "still working" "fd unchanged";
  out="$( 2>&1 echo "hello silence"; )";
  assert_eq "$out" "hello silence" "fd unchanged";

  if [[ "$-" != *e* ]]; then
    errchow "$FUNANAME: We need errexit";
  fi
}

test_boilerplate()
{
  # We cannot test whether all files keep these settings intact. But we can
  # verify that they come out of boilerplate.sh correctly.
  declare opt;
  for opt in e u E T; do # -h is not crucial
    assert_match "$-" "*${opt}*" "We need option ${opt}";
  done
  # shellcheck disable=SC2043
  for opt in "inherit_errexit"; do
    assert_eq "$(shopt -p "${opt}")" "shopt -s ${opt}" "We need shopt ${opt}";
  done
}

# Tests the availability (not function) of expected binaries etc.
test_environment()
{
  [[ "$-" == *e* ]] || return 1;
  run_silent_both "realpath" "/";
  run_silent_both "dirname" "/";
}

test_import()
{
  return 1;
}

test_init_standalone()
{
  ((loud_tests)) && echol "$FUNCNAME";
  # Use a nontrivial path to allow recursively testing the exported version.
  # Probably should not recurse more than once because the paths get longer.
  declare fake_project_dir="/tmp/command_test_init_standalone${dotfiles%/*}";
  declare -r show=0;
  rm -fr "$fake_project_dir";
  >/dev/null ensure_directory "$fake_project_dir";
  &>/dev/null subcommand rundir "$dotfiles" init_runscript --standalone --path="$fake_project_dir";
  ((show)) && tree "$fake_project_dir";
  # Test if initialized can be used. We answer yes/no to augmenting missing
  # versions so both cases are tested. If we need more input add accordingl.y
  if ((! loud_tests)) || test_user "Test instantiated standalone dotfiles?"; then
    &>/dev/null DOTFILES="$fake_project_dir/dotfiles_copy" "$fake_project_dir/run.sh" help <<< "ynynynynynynynynyn";
  else
    errchos "Not testing standalone export";
  fi
  echok "$FUNCNAME";
}

test_may_fail()
{
  test_may_fail_allow_success;
  test_may_fail_allow_failure;
  test_may_fail_exit;
  test_may_fail_normal_exit;
  test_may_fail_return;
  test_may_fail_options;
}

test_version()
{
  test_version_sensitivity;
  test_version_specificity;
  test_version_compare;
  test_version_compare_not;
  test_version_satisfied;
  test_version_satisfies_not;
}

# shellcheck disable=SC2178
# TODO Move the shel check to a separate bash script and just invoke it from the
# runscript.
command_shell_check()
{
  set_args "--no-pager --help --" "$@";
  eval "$get_args";
  pushd "$dotfiles";
  if (( $# == 0 )); then
    declare -a files;
    mapfile -t files < <(find . -iname "*.sh" -not -path "./extern/*");
  else
    declare -n files=argv;
#    files=("$@");
  fi
  ls --color=auto -FhA -- "${files[@]}";
  declare -i ret errors;
  if ! shellcheck -e SC2128,2154,2034 \
      --color=always \
      -x "${files[@]}" > shellcheck.txt 2>&1; then
    ret=0;
    # Count errors using grep (ignore ANSII codes)
    errors="$(grep -cEe $'^(\x1b\[[0-9;]*m)*In' shellcheck.txt)";
    echod "Found $errors errors in ${#files[@]} files";
  else
    ret=1;
    #errors="0";
  fi
  if [[ -s shellcheck.txt ]]; then
    if [[ "$no_pager" == "false" ]]; then batcat shellcheck.txt || :; fi
  fi
  if (( ret == 0 )); then
    errchow "ShellCheck ⛔ ${errors} problem(s)";
  else
    echok "ShellCheck ✅ ${#files[@]} file(s)";
  fi
  popd;
}

test_userinteractions()
{
  test_user_prompts;
}

test_setargs_all()
{
#  echol "$FUNCNAME";
  if [[ ! -v _run_config["declare_optionals"] ]]; then
    abort "$FUNCNAME: expected _run_config[\"declare_optionals\"] to be set";
  fi
  # We wrote most tests when the declare_optionals config didnt exist.
  # Temporarily disable the feature.
  declare -r old_optionals="${_run_config["declare_optionals"]}";
  _run_config["declare_optionals"]=0;

  # TODO Increase when adding new tests
  # TODO Determine automatically
  declare -i max=27
  declare -i t
  declare f;

  #"test_setargs_$max"
#  exit $?

  # GO backwards so we can more easily test the newest test when adding some
  for (( t=max; t >= 1; --t )); do
  #for (( t=1; t <= $max; ++t )); do
    f="test_setargs_${t}"
    "$f"
#    1>/dev/null "$f"
  done
  _run_config["declare_optionals"]="$old_optionals";

  echok "$FUNCNAME";
}

runscript_init_test()
{
  ((loud_tests)) && echol "$FUNCNAME";
  #if [[ -d /tmp/scripttest ]]; then
  #  errchon "Test diretory /tmp/scripttest exists alredy";
  #  test_user "Overwrite?" &&
  #    abort "Aborting. Treated as failure." ||
  #    errchol "Overwriting directory";
  #fi

  declare -r dir="/tmp/command_runscript_init_test";
  >/dev/null ensure_directory "$dir";
  rm -f "$dir/"*;
  &> /dev/null subcommand rundir "$dotfiles" init_runscript "$dir";
  declare -r out="$(command ls -1)";
  grep -q "run.sh" <<< "$out";

  # Print contents as well
  #ls --color=auto -lAFhtr "$dir";

  echok "$FUNCNAME";
}

deploy_test()
{
  ((loud_tests)) && echol "$FUNCNAME";
  declare -r test_dir="/tmp/command_deploy_test";
  declare -ri show_results=0;
  &>/dev/null ensure_directory "$test_dir";
  rm -f "$test_dir"/*;

  ((show_results)) && ls -alF "$test_dir";

  # Deploy arbitrary dotfile to a location in /tmp as test
  &>/dev/null subcommand rundir "$dotfiles" deploy "--file=$dotfiles/snippets/runscript.sh" "--dir=$test_dir" --name=abc --yes;
  ((show_results)) && ls -alF "$test_dir";
  [[ -h "$test_dir/abc" ]];
  #assert_eq "$(sed -nie '$=' -- "$test_dir/abc")" "1" "1.: Deploying as link is basically just a file with 1 line";

  &>/dev/null subcommand run "$dotfiles" deploy "--file=$dotfiles/snippets/runscript.sh" "--dir=$test_dir" --name=abc --yes <<< "y";
  ((show_results)) && ls -alF "$test_dir";
  [[ -h "$test_dir/abc" ]];
  #assert_eq "$(sed -ne '$=' -- "$test_dir/abc")" "1" "2.: Deploying as link is basically just a file with 1 line";

  # TODO Detect if the commands consumed stdin

  &>/dev/null subcommand run "$dotfiles" deploy --copy=true "--file=$dotfiles/snippets/runscript.sh" "--dir=$test_dir" --name=abc_copy --yes <<< "y";
  ((show_results)) && ls -alF "$test_dir";
  [[ -f "$test_dir/abc" ]];
  #assert_not_eq "$(sed -ne '$=' "$test_dir/abc")" "1" "3.: Deploying as copy produces more lines";
  #head -v "$test_dir/abc_copy"

  &>/dev/null subcommand run "$dotfiles" deploy --copy=true "--file=$dotfiles/snippets/runscript.sh" "--dir=$test_dir" --name=abc_copy --yes <<< "y";
  ((show_results)) && ls -alF "$test_dir";
  [[ -f "$test_dir/abc" ]];
  #assert_not_eq "$(sed -ne '$=' "$test_dir/abc")" "1" "4.: Deploying as copy produces more lines";
  #head -v "$test_dir/abc_copy"
  echok "$FUNCNAME";
}

# Terminal colors
# Terminal capabilities
# http://www.linuxcommand.org/lc3_adv_tput.php
# shellcheck disable=all
command_colour_test()
{
  #for (( i = 0; i < 256; i++ )); do echo -n "$(tput setaf $i)This is ($i) $(tput sgr0)	"; done

  # Test 24 bit colours
  true_colour_test;

  color2(){
    for c; do
        printf "$(tput setaf "$c")[%03d]" "$c"
#        printf '\e[48;5;%dm%03d' $c $c
    done
    printf '\e[0m \n'
  }

  IFS=$' \t\n'
  color2 {0..15}
  for ((i=0;i<6;i++)); do
      color2 $(seq $((i*36+16)) $((i*36+51)))
  done
  color2 {232..255}

  for fg_color in {0..16}; do
      set_foreground=$(tput setaf $fg_color)
      for bg_color in {0..7}; do
          set_background=$(tput setab $bg_color)
          echo -n $set_background$set_foreground
          printf " F:%02d ${text_bold}B:%02d $text_normal" $fg_color $bg_color
      done
      echo
      for bg_color in {8..16}; do
          set_background=$(tput setab $bg_color)
          echo -n $set_background$set_foreground
          printf " F:%02d ${text_bold}B:%02d $text_normal" $fg_color $bg_color
      done
      echo $(tput sgr0)
  done
#  for fg_color in {0..7}; do
#      set_foreground=$(tput setaf $fg_color)
#      for bg_color in {8..16}; do
#          set_background=$(tput setab $bg_color)
#          echo -n $set_background$set_foreground
#          printf " F:%s ${text_bold}B:%s $text_normal" $fg_color $bg_color
#      done
#      echo $(tput sgr0)
#  done

  color(){
    for c; do
        printf '\e[48;5;%dm %03d ' $c $c
    done
    printf '\e[0m \n'
  }

  IFS=$' \t\n'
  color {0..15}
  for ((i=0;i<6;i++)); do
      color $(seq $((i*36+16)) $((i*36+51)))
  done
  color {232..255}

  echou "Testing light pink";
  echo "${text_bold}${text_pink} [this]$text_normal is normal pink";
  echos "Testing light cyan";
  echo "${text_bold}${text_cyan} [this]$text_normal is normal cyan";
  echow "Testing light orange";
  echo "${text_bold}${text_orange} [this]$text_normal is normal orange";
  echoi "Testing light yellow";
  echo "${text_bold}${text_yellow} [this]$text_normal is normal yellow";
  echol "Testing light blue";
  echo "${text_bold}${text_blue} [this]$text_normal is normal blue";
  echoe "Testing light red";
  echo "${text_bold}${text_red} [this]$text_normal is normal red";
  echok "Testing light green";
  echo "${text_bold}${text_green} [this]$text_normal is normal green";
  echon "Testing pruple";
  echo "${text_bold}${text_purple} [this]$text_normal is normal purple";
  echo "${text_bold}[This]$text_normal is bold text";
  echo "${text_user}This is user$text_normal$text_user_soft and soft user $text_normal$text_user_hard and hard user text$text_normal";
}

################################################################################
# Helpers
################################################################################

should_fail()
{
  (
  declare _exit_code="";
  trap - ERR;
  set +e;
  ("$@"; )
  _exit_code="$?";
  set -e;
  assert_not_eq "$re" "0" "Test should exit nonzero";
  );
}

# ╭──────────────────────╮
# │ 🖹 Help strings       │
# ╰──────────────────────╯

declare -gr shell_check_help_string="Run ShellCheck
SYNOPSIS
  shell_check
  shell_check -- FILES...
DESCRIPTION
  Run ShellCheck on files passed from the perspective of the dotfiles root
  directory. When problems occur, batcat is opened on the output. If no files
  are given, run on all relevant bash files.
OPTIONS
  --no-pager: Do not use batcat to display output.";
