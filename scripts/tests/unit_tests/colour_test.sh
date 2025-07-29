#!/usr/bin/env bash

# version 0.0.0

# Copied stuff from online. Do not care to shellcheck until we write our own.
# shellcheck disable=all

true_colour_test() {
  #!/bin/bash
  #
  # https://gist.github.com/kariya-mitsuru/6338e61f2fb000bedd6d653aed4eec6e/revisions
  #
  #   This file echoes a bunch of 24-bit color codes
  #   to the terminal to demonstrate its functionality.
  #   The foreground escape sequence is ^[38;2;<r>;<g>;<b>m
  #   The background escape sequence is ^[48;2;<r>;<g>;<b>m
  #   <r> <g> <b> range from 0 to 255 inclusive.
  #   The escape sequence ^[0m returns output to default

  setBackgroundColor() {
    echo -en "\x1b[48;2;$1;$2;$3m "
  }

  resetOutput() {
    echo -e '\x1b[0m'
  }

  # Gives a color $1/255 % along HSV
  # Who knows what happens when $1 is outside 0-255
  # setBackgroundColor $red $green $blue where
  # $red $green and $blue are integers
  # ranging between 0 and 255 inclusive
  rainbowColor() {
    # Dodge errexit and ERR traps with ||:
    ((t = $1 % 43 * 255 / 43)) || :
    ((q = 255 - t))

    case "$(($1 / 43))" in
    0) setBackgroundColor 255 $t 0 ;;
    1) setBackgroundColor $q 255 0 ;;
    2) setBackgroundColor 0 255 $t ;;
    3) setBackgroundColor 0 $q 255 ;;
    4) setBackgroundColor $t 0 255 ;;
    5) setBackgroundColor 255 0 $q ;;
    *)
      abort "Unreachable"
      setBackgroundColor 0 0 0
      ;;
    esac
  }

  for i in {0..127}; do
    setBackgroundColor $i 0 0
  done
  resetOutput
  for i in {255..128}; do
    setBackgroundColor $i 0 0
  done
  resetOutput

  for i in {0..127}; do
    setBackgroundColor 0 $i 0
  done
  resetOutput
  for i in {255..128}; do
    setBackgroundColor 0 $i 0
  done
  resetOutput

  for i in {0..127}; do
    setBackgroundColor 0 0 $i
  done
  resetOutput
  for i in {255..128}; do
    setBackgroundColor 0 0 $i
  done
  resetOutput

  for i in {0..127}; do
    rainbowColor $i
  done
  resetOutput
  for i in {255..128}; do
    rainbowColor $i
  done
  resetOutput
}

# $1 name
# $2 Colour ansi sequence to be used
# $3 (optional) modifier
show_colour_helper() {
  echo "$text_normal$text_invert${3:-""}${2}" "          $text_normal$1"
}

test_black_and_white() {
  show_colour_helper "dim black" "$text_black" "$text_dim"
  show_colour_helper "black" "$text_black"
  show_colour_helper "dim bright black" "$text_brightblack" "$text_dim"
  show_colour_helper "bright black" "$text_brightblack"
  show_colour_helper "dim white" "$text_white" "$text_dim"
  show_colour_helper "dim bright white" "$text_brightwhite" "$text_dim"
  show_colour_helper "white" "$text_white"
  show_colour_helper "bright white" "$text_brightwhite"
}
