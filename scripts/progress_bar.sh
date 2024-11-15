#!/usr/bin/env bash

# version 0.0.0

declare -r tag="progress_bar"
if [[ -v _sourced_files["$tag"] ]]; then
  return 0
fi
_sourced_files["$tag"]=""

# Ensuring version even if included already
load_version "$dotfiles/scripts/version.sh" 0.0.0
#load_version "$dotfiles/scripts/assert.sh" 0.0.0
#load_version "$dotfiles/scripts/boilerplate.sh" 0.0.0
#load_version "$dotfiles/scripts/cache.sh" 0.0.0
#load_version "$dotfiles/scripts/error_handling.sh" 0.0.0
#load_version "$dotfiles/scripts/git_utils.sh" 0.0.0
#load_version "$dotfiles/scripts/progress_bar.sh" 0.0.0
#load_version "$dotfiles/scripts/setargs.sh" 0.0.0
load_version "$dotfiles/scripts/string.sh" 0.0.0
load_version "$dotfiles/scripts/termcap.sh" 0.0.0
load_version "$dotfiles/scripts/utils.sh" 0.0.0

declare -gr _progress_text_8="█"
declare -gr _progress_text_7="▉"
declare -gr _progress_text_6="▊"
declare -gr _progress_text_5="▋"
declare -gr _progress_text_4="▌"
declare -gr _progress_text_3="▍"
declare -gr _progress_text_2="▎"
declare -gr _progress_text_1="▏"
declare -gr _progress_text_0=" "

# Global variable saving length of last drawn box
declare -gi _progress_box_hight=0

# Sleep for $1 seconds and show a progress bar
# (!) Not exact.
# (!) Skips update sfor performance reasons.
#
# $1  (in)  Duration in seconds
# $2  (in)  Message
# $3  (in)  Length of progress bar
# $4  (in)  Box (true/false)
progress_sleep() {
  declare -i duration="${1:?progress_sleep: Missing argument}"
  declare -r msg="${2:-""}"
  declare -r len="${3:-"40"}"
  declare -r box="false"

  declare -i now
  now="$(date +%s)"
  declare -ir start=now
  declare -ir end=start+duration

  progress_push 0 "$duration" "$msg" "$len" "$box"
  while ((now < end)); do
    # Sleep 1/3 of time left
    #    sleep "$(( (end - now + 2) / 3))"
    sleep 1
    now="$(date +%s)"
    progress_update "$((now - start))" "$duration" "$msg" "$len" "$box"
  done
}

# Append line of progress bar.
# Usage: progress_push n max "message" [box=true|false]
#   n         Current progress
#   max       Maximum progress
#   len       Length of bar
#   message   ❕ Single line string printed after progress bar
progress_push() {
  # Calculate string
  declare n="${1:?Missing count}"
  declare max="${2:?Missing max count}"
  declare msg="${3:-""}"
  declare len="${4:-"20"}"
  declare box="${5:-"true"}"
  declare colourize="${6:-"${text_white}${background_brightblack}"}"
  declare sep="${7:-"│"}"

  msg="$n/$max $msg"
  declare str
  str="$colourize$(progress_bar_string "$n" "$len" "$max")$text_normal $msg"

  if [[ "$box" == "true" ]]; then
    box_down="$(repeat_string "$((len + ${#msg} + 1))" "─")"
    #  errchot "Len boxed string: ${#box_down}"
    box_up="╭${box_down}╮"
    box_down="╰${box_down}╯"
    str="│$str│"
    printf "%s\n%s\n%s\n" "$box_up" "$str" "$box_down"
    _progress_box_hight=3
  else
    printf "%s\n" "$str"
    _progress_box_hight=1
  fi
}
# Update existing progress bar (dont delete line, just overwrite)
# Usage: Same as progress_push
#
# The hope is that overwriting may produce less jitter if done often
progress_update() {
  __progress_go_back
  progress_push "$@"
}
# Remove line of progress bar
progress_pop() {
  __progress_go_back
  printf "%s" "${term_erase_forward}"
}
# Move back to start of progress print
__progress_go_back() {
  printf "%s" "$(repeat_string "$_progress_box_hight" "${term_up}")"
}

progress_detached() {
  for i in $(seq 0 100); do
    echo "Statement $i"
    printf "%s" "${term_save_cursor}${term_last_line}"
    printf "%s" "$(progress_bar_string "$i" 20) $i%"
    printf "%s" "${term_restore_cursor}"
    sleep 0.01
  done
  echo
}

# Produce blocks followed by spaces linked with appropriate 8th block to
# represent required percentage. Colourized white on bright black. Emits 'len'
# characters in total.
# With len=13:
#                 0%
# ▏               1%
# █▉             15%
# ███████████▋   90%
# ████████████▊  99%
# █████████████ 100%
# Use: printf "\r%s" "$(progress_bar_string $percent $len)"
progress_bar_string() {
  # Use pixels as length unit. Pixel = 1/8 character.
  declare -i percent="${1:?Missing percent}"
  declare -i len="8*${2:-"8"}" # Pixel length
  declare -i max="${3:-"100"}"

  declare -i full=$((percent * len / max))
  declare -i empty=len-full
  declare -i full_block=full/8
  declare -i full_residual=$((full - 8 * full_block)) # Do not show 0 residual later!
  declare -i empty_block=empty/8                      # Rest is handled by residual block
  if ((full_residual)); then
    declare -n residual="_progress_text_$full_residual"
  else
    declare residual=""
  fi

  declare front back
  front="$(repeat_string "$full_block" "$_progress_text_8")"
  back="$(repeat_string "$empty_block" "$_progress_text_0")"
  printf "%s" "${front}${residual}${back}"
  # Round down for full blocks
}

# TODO Function was for figuring this out. Can be removed now.
progress_test() {
  for i in $(seq 0 100); do
    printf "\r%s" "$(progress_bar_string "$i" 20) $i"
    sleep 0.01
  done
  echo
}

progress_test2() {
  declare -i max=20
  declare msg="Our nice message"
  progress_push 0 $max "$msg" 20 false
  sleep 1
  for i in $(seq 0 $max); do
    if ((i > 10 == 1)); then
      progress_pop
      echo "for loop with i=$i"
      progress_push "$i" "$max" "$msg" 20
    else
      progress_update "$i" "$max" "$msg" 20 false "${6:-"${text_white}${background_brightblack}"}" " "
    fi
    sleep 0.1
  done
  progress_update "$i" "$max" "$msg" 20 true "$text_green"
}

progress_test3() {
  declare -i max=49
  declare msg="progress_test3()"
  echo "We done with nothing"
  progress_push 0 "$max" "$msg" 20 true
  sleep 0.5
  for i in $(seq 0 "$max"); do
    if ((i > max / 2)); then
      progress_pop
      echo "We done with $i"
      progress_push "$i" "$max" "$msg" 20 true "$text_green$background_brightblack"
    else
      progress_update "$i" "$max" "$msg" 20
    fi
    sleep 0.1
  done
  echo
}
