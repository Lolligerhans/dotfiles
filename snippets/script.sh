#!/usr/bin/env bash
# ╭──────────────────────╮
# │ 🅅 ersion             │
# ╰──────────────────────╯
# version 0.0.0
# ╭──────────────────────╮
# │ 🛈 Info               │
# ╰──────────────────────╯
# Dotfiles script template
# ╭──────────────────────╮
# │ ⚙ Boilerplate        │
# ╰──────────────────────╯
# ❗ FIXME: Unique ID must be set when using this template
declare -r tag="unique_id";
if [[ -v _sourced_files["$tag"] ]]; then return 0; fi
_sourced_files["$tag"]="";
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
# │ 🖩 Utils              │
# ╰──────────────────────╯
# ╭──────────────────────╮
# │ 𝑓 Functional         │
# ╰──────────────────────╯
# ╭──────────────────────╮
# │ 🖹 Help strings       │
# ╰──────────────────────╯
# ╭──────────────────────╮
# │ 🕮  Documentation     │
# ╰──────────────────────╯
