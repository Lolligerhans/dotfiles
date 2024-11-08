#!/usr/bin/env bash
# ╭──────────────────────╮
# │ 🅅 ersion             │
# ╰──────────────────────╯
# version 0.0.0
# ╭──────────────────────╮
# │ 🛈 Info               │
# ╰──────────────────────╯
# ╭──────────────────────╮
# │ ⚙ Boilerplate        │
# ╰──────────────────────╯
declare -r tag="git_utils";
if [[ -v _sourced_files["$tag"] ]]; then return 0; fi
_sourced_files["$tag"]="";
# ╭──────────────────────╮
# │ 🗀 Dependencies       │
# ╰──────────────────────╯
# Ensuring version even if included already
load_version "$dotfiles/scripts/version.sh" 0.0.0;
#load_version "$dotfiles/scripts/assert.sh";
#load_version "$dotfiles/scripts/boilerplate.sh" 0.0.0;
#load_version "$dotfiles/scripts/cache.sh" 0.0.0;
#load_version "$dotfiles/scripts/error_handling.sh" 0.0.0;
#load_version "$dotfiles/scripts/git_utils.sh" 0.0.0;
#load_version "$dotfiles/scripts/progress_bar.sh" 0.0.0;
load_version "$dotfiles/scripts/setargs.sh" 0.0.0;
#load_version "$dotfiles/scripts/termcap.sh" 0.0.0;
load_version "$dotfiles/scripts/userinteracts.sh" 0.0.0;
load_version "$dotfiles/scripts/utils.sh" 0.0.0;
# ╭──────────────────────╮
# │ 🗺 Globals           │
# ╰──────────────────────╯
# ╭──────────────────────╮
# │ 🖩 Utils              │
# ╰──────────────────────╯
# Return 0 if clean, else return 1. Must be within git directory
git_test_clean()
{
  # TODO Verify that we are in a git directory (see how we do it in bash prompt)

  if [[ -z "$(git status --porcelain)" ]]; then
    return 0;
  else
    return 1;
  fi
}

# Writes "y" to reference variable $1 if clean, else writes "n".
git_is_clean()
{
  # TODO Verify that we are in a git directory (see how we do it in bash prompt)
  declare -n ret_4817932="${1}";
  declare output="";
  output="$(git status --porcelain)";
  if [[ -z "$output" ]]; then
    printf -v ret_4817932 -- "y";
  else
    printf -v ret_4817932 -- "n";
  fi
}

# Output how many commits $2 is ahead of $1.
# We do it this way around so that HEAD can be the default argument.
git_ahead_count()
{
  declare c1="${1:-"@{upstream}"}";
  declare c2="${2:-"HEAD"}";
  git rev-list --count "$c1".."$c2";
}

# Output how many commits $2 is behind $1.
# We do it this way around so that HEAD can be the default argument.
git_behind_count()
{
  declare c1="${1:-"@{upstream}"}";
  declare c2="${2:-"HEAD"}";
  git rev-list --count "${c2}..${c1}";
}

git_distance_count()
{
  declare c1="${1:-"@{upstream}"}";
  declare c2="${2:-"HEAD"}";
  git rev-list --count "$c1"..."$c2";
}

# Echo "true" if inside a git worktree, else echo "false"
git_is_worktree()
{
  git rev-parse --is-inside-work-tree;
}

# High-level helper to clone a repo
git_clone_repo()
{
  # Use default value "/" for '--name' because it is invalid as directory name
  set_args "--source= --path= --name=/ --branch --help" "$@";
  eval "$get_args";

  # Abort if path ends on "/" to avoid confusion.
  if [[ "${path: -1}" == "/" ]]; then abort "$FUNCNAME: Path must not end with /"; fi

  # If --name is missing, assume --path includes the name and extract it
  if [[ "$name" == "/" ]]; then
    name="$(basename "$path")";
    path="$(dirname "$path")";
  fi
  declare -r full_path="${path}/${name}";

  # Example:
  #     path=~/github
  #     name=repo
  #     full_path=~/github/repo

  # Sanity check
  if [[ -d "${full_path}" ]]; then
    echos "Repo $text_dim$full_path$text_normal already cloned";
    return 0;
  fi

  declare -r info_str="$text_user_soft$name$text_normal from $text_dim$source$text_normal to $text_dim$full_path$text_normal";
  {
    pushd "$path";
    git clone "$source" "$name";
    if [[ "$branch" != "false" ]]; then
      cd "$name";
      git checkout "$branch";
    fi
    popd;
    echok "Cloned $info_str";
  } ||
  { # FIXME The { } || { } construction does not work
    errchoe "Failed to clone $info_str";
  }
  return 0;
}

# Output name of current branch (or HEAD when no branch)
git_current_branch()
{
  git rev-parse --abbrev-ref HEAD;
}

# Get commit hash of current branch
# ($1  optional path to git directory)
git_current_commit()
{
  # Subshell so we need not cd back
  (
    (( $# > 0 )) && cd "$1";
    git rev-parse HEAD;
  )
}

git_current_remote_branch()
{
  errchof "No plumbing command yet";
  return 1;
}

git_fetch_master()
{
  # Fetch master branch from origin
  git fetch origin master;
  if (( $(git_ahead_count "origin/master" "master") != 0)); then
    abort "master is ahead of origin/master";
  fi
  # Merge fetched commits into local master (without checkout)
  declare -r before="$(git rev-parse master)";
  errchon "Before fetching: master=${before}"; # Print eagerly to ensure output on error
  git fetch . origin/master:master;
  declare -r after="$(git rev-parse master)";
  if [[ "$before" == "$after" ]]; then
    errchon "After fetching: (no change)";
  else
    errchon "After fetching: master=${after}";
  fi
  errchok "Done: Fetch 'origin/master' into 'master'";
}

git_rebase_ifneeded()
{
  set_args "--yes" "$@";
  eval "$get_args";

  declare branch master base clean;
  branch="$(git_current_branch)";
  git_is_clean clean;
  declare -r branch clean;

  # Sanity checks
  if [[ "$branch" == "HEAD" ]]; then abort "Detached-HEAD rebase not intended"; fi
  if [[ "$branch" == "master" ]]; then abort "Rebasing of master not intended"; fi
  if [[ "$clean" == "n" ]]; then abort "Repository unclean"; fi

  master="$(git show-ref --heads --hash master)";
  base="$(git merge-base "$branch" master)";
  declare -r master base;
  # TODO Could also use ahead count of master ahead of branch (?)
  if [[ "$master" == "$base" ]]; then
    errchos "[up-to-date] Rebasing $branch on master";
  else
    # TODO When origin/branch has commits we are lacking, we could lose them
    #      here. The update_fotfiles_branch currently avoids this by testing
    #      explicitly if origin/branch has diverged, but that means we have to
    #      manually recover every time we advance the branch on different
    #      machines. Still a bit risky.
    errchon "Before rebasing: $(git rev-parse HEAD)";
    git rebase master; # >/dev/null?
    errchon "After rebasing: $(git rev-parse HEAD)";
    errchok "Done: Rebasing $branch on master";
    git --no-pager s; echo; # Use our git aliases to display recent commits
    # FIXME Use boolean_prompt instead
    if [[ "$yes" == "true" ]] || test_user "Force-push rebase?"; then
      git push --force;
      errchok "Force-pushed rebase";
    fi
  fi
}

# ╭──────────────────────╮
# │ 𝑓 Functional         │
# ╰──────────────────────╯

# ╭──────────────────────╮
# │ 🖹 Help strings       │
# ╰──────────────────────╯

# shellcheck disable=SC2016 # Using ' instead of "
declare -r git_clone_repo_help_string='Clone a git repo
SYNOPSIS
  clone_repo --source=URL --path=PATH [--branch]
  clone_repo --source=URL --path=PARENT_PATH --name=NAME [--branch]
DESCRIPTION
  1. In the first form, clones a repo from URL into PATH, where $(basename PATH)
     will be used as the name of the created directory, and $(dirname PATH) will
     be used as the parent directory.
  2. In the second form, clones a repo from URL into PARENT_PATH/NAME.
  If the directory exists already, do nothing.
OPTIONS
  --source=URL: The URL of the repo to clone.
  --path=PATH: The path to create the rpository. When --name given, --path must
    not include the name. When --name is omitted, --path must include the name.
  --name=NAME: Use NAME as the name of the new directory, and --path as its
    parent.
  --branch=BRANCH: If present, checkout branch BRANCH after cloning the repo.';

# ╭──────────────────────╮
# │ 🕮  Documentation     │
# ╰──────────────────────╯
