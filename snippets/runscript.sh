#!/usr/bin/env bash
# ╭──────────────────────╮
# │ 🅅 version            │
# ╰──────────────────────╯
# version 0.0.0
# ╭──────────────────────╮
# │ 🛈 Info               │
# ╰──────────────────────╯
# Dotfiles runscript template
# ╭──────────────────────╮
# │ ⚙ Boilerplate        │
# ╰──────────────────────╯
declare -gr dotfiles="${DOTFILES:-"$HOME/dotfiles"}"; # TOKEN_DOTFILES_GLOBAL
# ☯ Every file prevents multi-loads itself using this global dict
declare -gA _sourced_files=( ["runscript"]="" ); # Source only once
# 🖈 If the runscript requires a specific location, set it here
#declare -gr this_location="";
source "$dotfiles/scripts/boilerplate.sh" "${BASH_SOURCE[0]}" "$@";
# ╭──────────────────────╮
# │ 🛠Configuration      │
# ╰──────────────────────╯
_run_config["versioning"]=1;
_run_config["log_loads"]=0;
#_run_config["error_frames"]=2;
# ╭──────────────────────╮
# │ 🗀 Dependencies       │
# ╰──────────────────────╯
# ✔ Ensure versions with satisfy_version
satisfy_version "$dotfiles/scripts/boilerplate.sh";
# ✔ Source versioned dependencies with load_version
load_version "$dotfiles/scripts/version.sh";
#load_version "$dotfiles/scripts/assert.sh";
#load_version "$dotfiles/scripts/bash_meta.sh";
#load_version "$dotfiles/scripts/cache.sh";
#load_version "$dotfiles/scripts/error_handling.sh";
#load_version "$dotfiles/scripts/fileinteracts.sh";
#load_version "$dotfiles/scripts/git_utils.sh";
#load_version "$dotfiles/scripts/progress_bar.sh";
#load_version "$dotfiles/scripts/setargs.sh";
#load_version "$dotfiles/scripts/termcap.sh";
#load_version "$dotfiles/scripts/userinteracts.sh";
#load_version "$dotfiles/scripts/utils.sh";
# ╭──────────────────────╮
# │ 🗺 Globals           │
# ╰──────────────────────╯
# ╭──────────────────────╮
# │ ⌨  Commands          │
# ╰──────────────────────╯

# Default command (when no arguments are given)
command_default()
{
  echo "Not implemented yet";

}

# ╭──────────────────────╮
# │ 🖩 Utils              │
# ╰──────────────────────╯
# ╭──────────────────────╮
# │ 𝑓 Functional         │
# ╰──────────────────────╯
# ╭──────────────────────╮
# │ 🖹 Help strings       │
# ╰──────────────────────╯
#declare -r default_help_string='';
# ╭──────────────────────╮
# │ ⚙ Boilerplate        │
# ╰──────────────────────╯
# ⌂ Transition to provided command
subcommand "${@}";
# ╭──────────────────────╮
# │ 🕮  Documentation     │
# ╰──────────────────────╯
