#!/usr/bin/env bash

# version 0.0.0

# Workspace installation functions.

# +----------------------+
# | 🛈 Info               |
# +----------------------+
# ❗ Only sourced by dotfiles/scripts/install/run.sh
# +----------------------+
# | Config ⚙             |
# +----------------------+
#declare -ig error_handling_frames=2
# +----------------------+
# | Includes             |
# +----------------------+
#source "$dotfiles"/scripts/git_utils.sh
#source "$dotfiles"/scripts/progress_bar.sh
#source "$dotfiles"/scripts/cache.sh

# Ensuring version even if included already
load_version "$dotfiles/scripts/version.sh" 0.0.0
#load_version "$dotfiles/scripts/assert.sh" 0.0.0
#load_version "$dotfiles/scripts/boilerplate.sh" 0.0.0
#load_version "$dotfiles/scripts/cache.sh" 0.0.0
#load_version "$dotfiles/scripts/error_handling.sh" 0.0.0
load_version "$dotfiles/scripts/git_utils.sh" "0.0.0"
#load_version "$dotfiles/scripts/progress_bar.sh" 0.0.0
load_version "$dotfiles/scripts/setargs.sh" 0.0.0
load_version "$dotfiles/scripts/termcap.sh" 0.0.0
load_version "$dotfiles/scripts/utils.sh" 0.0.0

# +----------------------+
# | Constants            |
# +----------------------+

# +----------------------+
# | Commands             |
# +----------------------+

workspace_list() {
  echon "Available workspaces:"

  declare -a funcs
  mapfile -t funcs < <(declare -F | command sed -n 's/.*prepare_\([a-zA-Z]\+\)_workspace.*/\1/p')
  #  declare -F
  #  declare -F | command sed -n 's/.*prepare_\([a-zA-Z]\+\)_workspace.*/\1/p'
  #  errchof "funcs: [${funcs[@]}]"
  declare w
  for w in "${funcs[@]}"; do
    echo "  • $w"
  done
}

# ❗ The naming scheme for preparation commands MUST be consistent (we use
#    grep/sed on the function names). Scheme:
#       prepare_[name]_workspace
#    where [name] is replaced by the name of the workspace.

# Optional: TOKEN_DOTFILES_WORKSPACEOTHER_PREPARATIONS
# prepare_<name>_workspace()
# {
#   :; # ...
# }

prepare_example_workspace() {
  abort "This is a dummy workspace"
  declare -r src="https://github.com/example/example.git"
  git_clone_repo --source="${src}" --path="$HOME/github/example"
}

prepare_dotfiles_workspace() {
  echof "This does nothing at the moment (testing only)"
  echof "What is that supposed to do?"
}

# +----------------------+
# | Utils                |
# +----------------------+
