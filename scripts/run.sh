#!/usr/bin/env bash

declare -gr dotfiles="${DOTFILES:-"$HOME/dotfiles"}"; # TOKEN_DOTFILES_GLOBAL
declare -gA _sourced_files=( ["runscript"]="" );
source "$dotfiles/scripts/boilerplate.sh" "${BASH_SOURCE}" "$@";
#load_version "$dotfiles/scripts/run1.sh" 0.0.0; # TODO Rename function to version_ensure

# ┌────────────────────────┐
# │ Info                   │
# └────────────────────────┘

# THIS IS NOT A DOTFILE

# This file contains the commands for the runscript of this directory. For the
# tempalte dotfile for "commands.sh", see snippets/run_commands.sh.

# ┌────────────────────────┐
# │ Config                 │
# └────────────────────────┘

# Reduce error printing:
_run_config["error_frames"]=2;

# ┌────────────────────────┐
# │ Includes               │
# └────────────────────────┘

load_version "$dotfiles/scripts/setargs.sh" 0.0.0;
load_version colours.sh 0.0.0; # TODO use?

# Ensuring version even if included already
load_version "$dotfiles/scripts/version.sh" 0.0.0;
#load_version "$dotfiles/scripts/assert.sh" 0.0.0;
#load_version "$dotfiles/scripts/boilerplate.sh" 0.0.0;
#load_version "$dotfiles/scripts/cache.sh" 0.0.0;
#load_version "$dotfiles/scripts/error_handling.sh" 0.0.0;
#load_version "$dotfiles/scripts/git_utils.sh" 0.0.0;
#load_version "$dotfiles/scripts/progress_bar.sh" 0.0.0;
#load_version "$dotfiles/scripts/setargs.sh" 0.0.0;
load_version "$dotfiles/scripts/termcap.sh" 0.0.0;
load_version "$dotfiles/scripts/utils.sh" 0.0.0;

# ┌────────────────────────┐
# │ Constants              │
# └────────────────────────┘

declare -r completion_script="$dotfiles/dot/bash_completion.sh";

# ┌────────────────────────┐
# │ Commands               │
# └────────────────────────┘

command_test_colours_script()
{
  echol "Saturate value test";
  for sat in 50 75; do
    for i in {0..16}; do
      declare -i val=$((i * 16));
      if ((val == 256)); then val=255; fi
      printf "Saturate $sat: (%d — %x ➜ %x)\n" "$val" "$val" "$("saturate_$sat" "$val")";
    done
  done
}

# Default command (when no arguments are given)
command_default()
{
  errchot "Copy the following alias ${text_bold}t$text_normal to source $text_italic$completion_script$text_normal:";
  # shellcheck disable=2016
  echo 'alias t="source $completion_script"';
  # shellcheck disable=2139
  alias t='source $completion_script';
  # nshellcheck disable=2134
}

# ┌────────────────────────┐
# │ Helpers                │
# └────────────────────────┘

# Transition to provided command
subcommand "${@}";
