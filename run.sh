#!/usr/bin/env bash

# shellcheck disable=2219

# ╭──────────────────────╮
# │ 🛈 Info               │
# ╰──────────────────────╯

# ╭──────────────────────╮
# │ ⚙ Boilerplate        │
# ╰──────────────────────╯

declare -gr dotfiles="${DOTFILES:-"$HOME/dotfiles"}" # TOKEN_DOTFILES_GLOBAL
declare -gA _sourced_files=(["runscript"]="")
declare -gr this_location=""
# shellcheck source-path=./scripts/boilerplate.sh
source "$dotfiles/scripts/boilerplate.sh" "${BASH_SOURCE[0]}" "$@"
satisfy_version "$dotfiles/scripts/boilerplate.sh" 0.0.0

# ╭──────────────────────╮
# │ 🛠 Configuration     │
# ╰──────────────────────╯

#_run_config["log_loads"]=1
#_run_config[error_frames]=2
#_run_config["versioning"]=0

# ╭──────────────────────╮
# │ 🗀 Dependencies       │
# ╰──────────────────────╯

load_version "$dotfiles/scripts/version.sh" 0.0.0
load_version "$dotfiles/scripts/bash_meta.sh" 0.0.0
load_version "$dotfiles/scripts/cache.sh" 0.0.0
load_version "$dotfiles/scripts/fileinteracts.sh" 0.0.0
load_version "$dotfiles/scripts/git_utils.sh" 0.0.0
load_version "$dotfiles/scripts/progress_bar.sh" 0.0.0
load_version "$dotfiles/scripts/setargs.sh" 0.0.0
load_version "$dotfiles/scripts/termcap.sh" 0.0.0
load_version "$dotfiles/scripts/userinteracts.sh" 0.0.0
load_version "$dotfiles/scripts/utils.sh" 0.0.0

# ╭──────────────────────╮
# │ 🗺 Globals           │
# ╰──────────────────────╯

declare -r restoration_script="$dotfiles/snippets/restoration.sh"
declare -r restoration_default_destination="$HOME/Backups/"
declare -r stick_name="UBUNTU_STIC"
declare -r restoration_tmp_path="/tmp/restoration_tmp"
declare -r restoration_stick_path="/media/${USER}/${stick_name}/MY_BACKUP/"
declare -ar restoration_files=(
  # I think the restoratino process is such that all paths MSUT be withing
  # $HOME, including $dotfiles.
  # TODO: Verify this need.
  "${dotfiles}"
  "${HOME}/.ssh"/id*
  "${HOME}/.ssh/known_hosts"
  "${HOME}/snap/firefox/common/.mozilla/firefox/"
  "${HOME}/Documents/behoerden/"
  "${HOME}/Documents/jobs/"
  "${HOME}/Documents/books/"
  "${HOME}/.bash_aliases_local"
)
declare -r update_alternatives_default_link="/usr/bin"

# ╭──────────────────────╮
# │ ⌨  Commands          │
# ╰──────────────────────╯

# Default command (when no arguments are given)
# shellcheck disable=2317,2120 # unreachable, no args passed
command_default() {
  # set_args "--help" "$@"
  # eval "$get_args"

  subcommand run scripts/tests
  # subcommand "help" "$@"
}

command_test() {
  set_args "--help" "$@"
  eval "$get_args"

  # Order so that we need not scroll output much
  subcommand rundir scripts/tests test --all
}

command_nvim() {
  set_args "--help --backup --restore" "$@"
  eval "$get_args"

  declare -r extension="runscriptbackup"

  if [[ "$backup" == "true" && "$restore" == "true" ]]; then
    abort "Must pass exactly one option"
  fi

  if [[ "$backup" == "true" ]]; then
    echol "Backing up nvim config"
    command mv ~/.config/nvim{,."$extension"}
    command mv ~/.local/share/nvim{,."$extension"}
    command mv ~/.local/state/nvim{,."$extension"}
    command mv ~/.cache/nvim{,."$extension"}
  fi

  if [[ "$restore" == "true" ]]; then
    echol "Restoring nvim config"
    command mv ~/.config/nvim{."$extension",}
    command mv ~/.local/share/nvim{."$extension",}
    command mv ~/.local/state/nvim{."$extension",}
    command mv ~/.cache/nvim{."$extension",}
  fi

  echon "Curretn state:"
  command ls --color=auto -Fh -A -ltr ~/.config/ | command grep nvim
  command ls --color=auto -Fh -A -ltr ~/.local/share/ | command grep nvim
  command ls --color=auto -Fh -A -ltr ~/.local/state/ | command grep nvim
  command ls --color=auto -Fh -A -ltr ~/.cache/ | command grep nvim
}

command_unun() {
  set_args "--help" "$@"
  eval "$get_args"

  # Glob for .filename.un~
  if command rm -v "$caller_path"/.*.un~; then
    echok "Removed undofiles"
  else
    echow "Failed to remove undofiles"
  fi
}

command_alias() {
  set_args "--name=? --value=? --delete --help" "$@"
  eval "$get_args"

  declare -r aliases_file="${HOME}/.bash_aliases_local"
  show_variable aliases_file

  # Disallow --value and --delete at the same time
  if [[ "$value" != "?" && "$delete" != "false" ]]; then
    show_variable value
    show_variable delete
    abort "Options --value and --delete cannot be used at the same time"
  fi

  command touch "$aliases_file"

  # Show all aliases when no name is provided
  if [[ "$name" == "?" ]]; then
    command batcat "$aliases_file"
    return 0
  fi

  # Makes valid alias and allows using $name in regex patterns
  declare -r valid_name='+([_.[:alnum:]-])'
  # shellcheck disable=SC2053
  if [[ "$name" != $valid_name ]]; then
    show_variable name
    show_variable valid_name
    abort "Name invalid"
  fi

  if [[ "$delete" == "true" ]]; then
    subcommand alias "$name" # Show existing one
    command sed -ie "/^alias ${name}=/d" "$aliases_file"
    echok "Removed alias $name"
    return 0
  fi

  # HACK: Show current entry when value is "false" (i.e., not provided to
  #       set_args).
  if [[ "$value" == "?" ]]; then
    if command grep -e "^alias ${name}=" "$aliases_file"; then
      echon "✅ Alias $text_user_soft$name$text_normal found"
    else
      echon "❎ Alias $text_user_soft$name$text_normal not found"
    fi
    return 0
  fi

  subcommand alias --delete "$name" # Delete existing one

  # Add new alias
  echo "alias $name=${value@Q}" >>"$aliases_file"
  echok "Added alias $text_user_soft$name$text_normal"
}

command_clear_cache() {
  set_args "--help" "$@"
  eval "$get_args"

  cache_clear
}

command_timer() {
  set_args "--duration=4 --unit=m --message=timer --no-beep --no-console --help" "$@"
  eval "$get_args"

  declare -Ar seconds_map=(
    ["s"]="1"
    ["m"]="60"
  )

  # Sanity check
  if ! >/dev/null 2>&1 notify-send --version; then
    abort "${FUNCNAME[0]}: notify-send not installed"
  fi

  if [[ ! -v seconds_map["$unit"] ]]; then
    show_variable seconds_map
    abort "Invalid unit"
  fi

  if [[ "$duration" != +([[:digit:]]) ]]; then
    show_variable duration
    abort "Duration must contain digits only"
  fi

  {
    declare -ri factor="${seconds_map[$unit]}"
    command sleep "$((duration * factor))"
    # This is the predefined 'alert' alias in Ubuntu 20
    command notify-send "$message ($duration$unit)"
    if [[ "$no_beep" == "false" ]]; then
      # Beep sound
      printf -- "\a"
    fi
    if [[ "$no_console" == "false" ]]; then
      echou "$message ($duration$unit)"
    fi
  } &
  declare -ri pid="${!}"
  disown "$pid"

  echok "Started ${duration}${unit} timer with pid $pid"
}

command_update_alternatives() {
  set_args "--path= --name --link --priority --dry-run --yes --help" "$@"
  eval "$get_args"

  #  echou "${FUNCNAME[0]}: testing is on"
  #  echoi "$(print_values_decorate Args "" "" $@)"
  #  declare dry_run="true"

  if [[ "${path:0:1}" != "/" ]]; then
    declare _before="${path}"
    path="$(which "$path")" || abort "${FUNCNAME[0]}: --path (${text_dim}$_before${text_normal}) inaccessible for 'which'"
    echon "Which'd relative path $text_dim${_before}$text_normal ➜ $text_dim$path$text_normal"
  fi

  # Split version string to get --name
  if [[ "$name" == "false" ]]; then # We cannot name a program "false"
    # Need shopt extglob
    # TODO Use regex to extract all trailing digits, dashes and periods (?)
    declare -r pattern="-+([[:digit:]])"
    # shellcheck disable=2295
    declare -r no_version="${path%%$pattern}"
    declare -ir len_noversion="$((${#no_version} + 1))" # Hyphen-minus takes 1 character
    #echoi "path=$path"
    #echoi "#path=${#path}"
    #echoi "no_version=$no_version"
    #echoi "len_noversion=$len_noversion"
    if ((len_noversion >= ${#path})); then
      abort "${FUNCNAME[0]}: Could not deduce name from $text_dim$path$text_normal"
    fi
    declare -r ua_name="$(basename "$no_version")"
  else
    declare -r ua_name="$name"
  fi

  # Deduce link
  if [[ "$link" == "false" ]]; then
    declare -r ua_link="${update_alternatives_default_link}/${ua_name}"
  else
    declare -r ua_link="$link"
  fi

  # Deduce version/priority
  if [[ "$priority" == "false" ]]; then
    if [[ "$ua_name" == *[[:digit:]]* ]]; then
      abort "${FUNCNAME[0]}: Not deducing priority with more digits contained in $text_dim$ua_name$text_normal"
    fi
    declare -r ua_priority="${path:$len_noversion}"
    if [[ "${ua_priority:0:1}" == "0" ]]; then # start:len
      abort "${FUNCNAME[0]}: Deduced priority starts with '0' in $text_dim$ua_priority$text_normal"
    fi
  else
    declare -r ua_priority="$priority"
  fi

  # Sanity check
  if [[ ! -e "$path" ]]; then
    echoe "Binary $text_dim$path$text_normal not found"
    if [[ "$dry_run" == "true" ]]; then
      echon "continuing despite missing binary (--dry-run)"
    else
      abort "Binary not found"
    fi
  fi

  echoi "ua_link: $text_dim$ua_link$text_normal"
  echoi "ua_name: $text_dim$ua_name$text_normal"
  echoi "ua_path: $text_dim$path$text_normal"
  echoi "ua_prio: $text_dim$ua_priority$text_normal"
  declare -ra params=("$ua_link" "$ua_name" "$path" "$ua_priority")
  echon "Command: 'update-alternatives --install \"\$@\": $(print_values_decorate "ARGS" "" "" "${params[@]}")'"
  if [[ "$dry_run" == "true" ]]; then
    return 0
  fi

  # Pass to update-alternat
  # TODO When we feel comfortable with the command we can add a --yes parameter
  #      to skip the confirmation.
  if [[ "$yes" == "true" ]] || [[ "$(ask_user " Parameters ok?")" == "true" ]]; then
    set -x
    sudo update-alternatives --install "${params[@]}"
    set +x
    echok "update-alternative for $text_dim$ua_name$text_normal installed: $text_dim$path$text_normal"
  else
    echos "Update-alternatives not run"
  fi
  set -x
  update-alternatives --list "$ua_name"
  set +x
}

command_restoration_tarball() {
  set_args "--name=backup --destination=$restoration_default_destination --move --stick --test_unpacking --verbose --help" "$@"
  eval "$get_args"

  # Special case: --stick overwrites destination/move
  if [[ "$stick" == "true" ]]; then
    # When --move is active, overwrite that and leave --destination alone. When
    # only --destination is used, overwrite that.
    if [[ "$move" != "false" ]]; then
      move="$restoration_stick_path"
    else
      destination="$restoration_stick_path"
    fi
  fi

  # Special case: no-argument --move: Borrow --destination and give tmp
  # directory to --destination instead.
  if [[ "$move" == "true" ]]; then
    # Set but no argument passed. Canno use default path for destination since
    # --move might get it.
    move="$destination"
    rm -rf -- "$restoration_tmp_path"
    ensure_directory "$restoration_tmp_path"
    destination="$restoration_tmp_path"
  fi

  # Sanity check destination
  if [[ "$destination" == "$restoration_default_destination" ]]; then
    ensure_directory "$destination"
  else
    if [[ ! -d "$destination" ]]; then
      echon "Destination $text_dim$destination$text_normal does not exist yet"
      if [[ "$(ask_user "Create now?")" == "true" ]]; then
        ensure_directory "$destination"
      else
        abort "Directory $text_bold$destination$text_normal not found"
      fi
    fi
  fi

  declare tar_flag=""
  [[ "$verbose" == "true" ]] && tar_flag="v"

  declare -r timestamp="$(date_nocolon)"
  declare -r nodename="$(uname -n)"
  declare -r name_timestamp_nodename="${name}_${timestamp}_${nodename}"
  declare -r toplevel_dir="$destination/$name_timestamp_nodename"
  declare -r filename="$name_timestamp_nodename.tar.bz2"
  declare -r backup_path="$toplevel_dir/$filename"

  # Create backup tarball
  echoi "Backing up:"
  declare file
  for file in "${restoration_files[@]}"; do
    echon "  • $text_dim$file$text_normal"
  done
  echoi "Backup destination: $text_dim$destination$text_normal"
  echoi "Name: $text_dim$filename$text_normal"
  echoi "Backup directory: $text_dim$name_timestamp_nodename$text_normal"
  echoi "Creating backup $text_dim$toplevel_dir$text_normal"
  mkdir -vp "$toplevel_dir"

  #{
  #echon "Trying first time with relative path"
  #pushd "$destination"
  #mkdir -vp "$name_timestamp_nodename" && # mkdir -vp does not work through /media/... so cd there first
  #popd; } ||
  #{
  #  echoi "Trying with full path"
  #}

  tar --force-local -${tar_flag}cjSpf "${backup_path}" "${restoration_files[@]}"
  # -p: Preserve permissions
  echok "Created backup tarball"

  # Add restoration script
  declare -r restoration_target="$toplevel_dir/restoration-$name_timestamp_nodename.sh"
  cp -v "$restoration_script" "$restoration_target"
  declare -r token_value="TOKEN_backup_name"
  declare -r replacement_line="declare -r backup_name=\"$filename\"; # TOKEN_name_was_given"
  # shellcheck disable=SC1003
  sed -i -e '/'"$token_value"'/c \'"$replacement_line"'' "$restoration_target"
  chmod +x "$restoration_target"
  echok "Created restoration script"

  # Unpack tarball again. You can remove this eventually when if it works.
  if [[ "$test_unpacking" == "true" ]]; then
    echon "Unpacking backup for testing: $text_dim$backup_path$text_normal"
    tar -C "$toplevel_dir" -xjpf "${backup_path}"
    pushd "$toplevel_dir"
    tree -aDL 3
    popd
    echok "Unpacked backup"
  fi

  # Move backup (if needed)
  # NOTE: We use the new declare-optionals setargs config ☺
  if [[ "$move" != "false" ]]; then
    echol "Moving finished backup to move destination $text_dim$move$text_normal"
    mv -v "$toplevel_dir" "$move"
    echok "Moved backup to $text_dim$move$text_normal"
  fi
}

command_wipe_cache() {
  set_args "--help" "$@"
  eval "$get_args"
  rm -vr ~/dotfiles/scripts/.cache/
}

command_upgrade() {
  set_args "--daily --with-new-pkgs --help" "$@"
  eval "$get_args"

  # (!) Force upgrade resets the daily cache on error. Dont use in scripts.
  declare update_needed
  update_needed="$(cache_daily "upgrade" "get")"
  if [[ "$daily" != "true" ]] || [[ "$update_needed" == "true" ]]; then
    # TODO More readable version
    {
      echol "Upgrading apt packages" &&
        sudo apt-get update && sudo apt-get upgrade -y &&
        echok "apt upgrade"
      if [[ "$with_new_pkgs" == "true" ]]; then
        sudo apt --with-new-pkgs upgrade
      fi
      echol "Upgrading snap packages" &&
        sudo snap refresh &&
        echok "snap refresh"
      cache_daily "upgrade" "set" >/dev/null
    } ||
      {
        cache_daily "upgrade" "reset"
        errchoe "Failed to upgrade apt/snap packages. Will try again next time"
      }
  else
    echos "(daily) apt/snap upgrades"
  fi
}

command_shutdown_upgrade() {
  set_args "--timer=60 --help" "$@"
  eval "$get_args"

  #may_fail -- subcommand update_dotfiles_branch

  may_fail -- subcommand upgrade --daily

  shutdown_timer "$timer"
}

# This command updates the current dotfiles branch. Every branch should specify
# its own version (for example, to auto-rebase on master).
# TODO: I think this function and everything below could be removed?
command_update_dotfiles_branch() {
  set_args "--help" "$@"
  eval "$get_args"

  # Sanity check
  declare work_tree
  work_tree="$(git_is_worktree)"
  if [[ "$work_tree" != "true" ]]; then abort "dotfiles should be a git repo"; fi
  if ! git_test_clean; then abort "Clean repository before updating"; fi
  declare branch remote_branch
  branch="$(git_current_branch)"
  if [[ "$branch" == "HEAD" ]]; then
    abort "update_dotfiles_branch: HEAD detached"
  fi
  remote_branch="$(git rev-parse --abbrev-ref --symbolic-full-name "@{upstream}")"

  # FIXME How to read remote name from script reliably?
  if [[ "$remote_branch" != "origin/$branch" ]]; then
    errchof "How to read name of remote fromscript??"
    abort "This only works for remote origin currently"
  fi

  # Fetch remote branch (must be set up)
  git fetch origin "$branch" # FIXME Hard-coded remote "origin" cause I dont know how else
  declare -i ahead behind
  ahead="$(git_ahead_count)" # TODO Ahead-behind function returning both?
  behind="$(git_behind_count)"

  # Special case: out of sync
  if ((ahead && behind)); then
    abort "Local branch $branch out-of-sync with ${remote_branch}"
  fi

  # Special case: up to date
  if ! ((ahead || behind)); then
    errchos "[up-to-date] Snyc remote-tracking-branch ${remote_branch}"
    # Do big if instead of return because other branches add things below
  else
    # Sync local branch with remote branch
    if ((ahead != 0)); then
      # behind == 0
      git push
      errchok "Pushed $branch ➜ $remote_branch"
    elif ((behind != 0)); then
      # Fast-forward merge
      git merge --ff-only "$remote_branch"
      errchok "Fast-forward merge remote-tracking branch ${remote_branch} ➜ ${branch}"
    else
      abort "Unreachable" "return"
    fi
  fi

  # Mandatory: TOKEN_DOTFILES_BRANCH_PREPARATIONS
  # Uncomment in non-master branches when rebasing is desired workflow.
  # This makes the 'update_dotfiles_branch' command (invoked also through
  # 'shutdown_upgrade') rebase on the master branch.
  #rebase_on_master_helper --yes="true"
}

command_colours() {
  set_args "--help" "$@"
  eval "$get_args"

  # Access the useful colour tests from /scripts/tests from within dotfiles/
  subcommand rundir scripts/tests/ test --colour
}

command_termcaps_manpage() {
  set_args "--help" "$@"
  eval "$get_args"
  print_and_execute "man" "terminfo"
}

command_install() {
  # Invoke default command to install dotfiles
  subcommand rundir scripts/install "$@"
}

# Copy dotfiles directory to another location, but only files that are relevant
# from scripting. As a current snapshot of the dotfiles.
#
# Output: Path of new dotfiles (input --path + "/" + name)
command_export_dotfiles_scripts_standalone() {
  set_args "--path= --name=dotfiles_copy --yes --help" "$@"
  eval "$get_args"

  # If we export anything but the msater branch, give a warning
  {
    declare git_br
    git_br="$(git_current_branch)"
    errcho
    errchow "======================================="
    errchow "Exporting branch ${text_user_hard}${git_br}${text_normal}"
    errchow "======================================="
    errcho
    if [[ "$git_br" != "master" ]]; then
      declare choice="n"
      if [[ "$yes" == "true" ]]; then
        choice="y"
      else
        >&2 boolean_prompt "Export non-master branch?" choice
      fi
      if [[ "$choice" == "n" ]]; then
        abort "Aborted by user"
      fi
    fi
  }

  # Sanitize (optional - remove if needed)
  errchon "Sanitizing export dotfiles arguments. Remove if needed."
  if [[ "$path" != /tmp/* ]]; then
    errchon "path=$path"
    abort "export_dotfiles_scripts_standalone: aborted (safe mode): $path"
  fi
  if [[ "${path:0:1}" != "/" ]]; then
    errchon "path=$path"
    abort "export_dotfiles_scripts_standalone: You probabl want to export to a full path only"
  fi

  # Sanitize (required)
  declare -r glob_dotf=~/dotfiles/ # Use ~ expansion
  if [[ ! "$dotfiles" -ef "$glob_dotf" ]] ||
    [[ ! "$parent_path" -ef "$glob_dotf" ]]; then
    errchow "You probably only want to export the original dotfiles/ directory from the original runscript"
    errchon "path=$path dotfiles=$dotfiles parent_path=$parent_path"
  fi
  declare -r copy_path="$path/$name"
  if [[ -d "$copy_path" ]]; then
    abort "export_dotfiles_scripts_standalone: Directory '$copy_path' exists already"
  fi
  if [[ ! -d "$path" ]]; then
    abort "export_dotfiles_scripts_standalone: Directory '$path' not found. Did you want to export there? Then create it first."
  fi

  # Copy files
  1>&2 ensure_directory "$copy_path" # Keep stdout free for $copy_path
  errchol "Copying dotfiles scripts to $text_dim$copy_path$text_normal"
  declare -a files
  # Find with relative path means we must be at correct location.
  [[ "$dotfiles/" -ef "./" ]]
  mapfile -t files < <(command find . -name "*.sh") # TODO Does this work?
  declare file
  for file in "${files[@]}"; do
    1>&2 cp --path "$file" "$copy_path"
  done

  # Edit runscript as needed
  declare -a new_runscripts=(
    "$copy_path/snippets/runscript.sh"
    "$copy_path/snippets/runscript_extended.sh"
  ) # TODO can this handle spaces?
  mapfile -t -O "${#new_runscripts[@]}" new_runscripts < <(
    find "$copy_path" -name "run.sh"
  )
  declare -r new_runscripts
  errchol "Editing" "${new_runscripts[@]}"
  declare -r token="token_dotfiles_global"
  # shellcheck disable=SC2016
  declare -r newline='declare -gr dotfiles="${DOTFILES:-"'"$copy_path"'"}"; # ${token@U}'
  declare rs=""
  for rs in "${new_runscripts[@]}"; do
    #    errchof "Editing file $rs"
    # shellcheck disable=SC1003
    1>&2 sed -i -e '/'"${token@U}"'/c \'"$newline"'' "$rs"
    # This test only makes sense when we replace the token, but then we cannot
    # double-test the standalone exported version.
    #    if ! 1>&2 grep -qe "${token@U}" "$rs"; then
    #      abort "Something went wrong changing the dotfiles variable in $rs"
    #    fi
  done

  # (!) We deploy as link to the copied run_script.sh
  #  errchol "Remote deploying runscript as link-to-copy"
  #  1>&2 subcommand deploy --yes --name=run.sh --file "$copy_path/scripts/run_script.sh" --dir "$copy_path"

  # Output new dotfiles path (so caller must not know the default name)
  # TODO Maybe we should just require a name.
  printf "%s" "$path/$name"
  errchok "Done: exporting dotfiles to $copy_path"
  return 0
}

command_init_runscript() {
  # Use caller working directory when called without path argument
  set_args "--path=$caller_path --extended=false --standalone --confirm=false --yes --help" "$@"
  eval "$get_args"

  declare -r init_path="$path"

  # Sanitize
  if [[ "${init_path:0:1}" != "/" ]]; then
    errchon "Move this sanity check into --standalone case if you want to do this"
    abort "$0 init_ruscript: Refusing to init at relative path $init_path"
  fi

  # Special case --standalone:
  # Generate standalone dotfiles copy and delegate the task to the copy
  if [[ "$standalone" == "true" ]]; then
    declare new_dotfiles_dir
    new_dotfiles_dir="$(subcommand export_dotfiles_scripts_standalone "$init_path" --yes="$yes")"
    declare -r new_dotfiles_dir
    subcommand rundir "${new_dotfiles_dir}" init_runscript --path="$path" --confirm="$confirm" --extended="$extended"
    return 0
  fi

  if [[ "$confirm" != "false" ]] && ! [[ "$(ask_user "Initialize runscript at $text_italic$init_path$text_normal?")" == "true" ]]; then
    errchon "Not initializing at $init_path"
    return 0
  fi

  if [[ ! -d "$init_path" ]]; then abort "Directory ${text_bold}$init_path${text_normal} does not exist"; fi
  declare has_run="0"

  errchol "Initializing runscript at location $text_italic$init_path$text_normal..."

  # Warn if files already present
  if [[ -f "$init_path/run.sh" ]]; then
    errchow "$init_path/run.sh already exists"
    has_run="1"
  fi

  # Select files depending on --extended
  if [[ "$extended" == "false" ]]; then
    declare -r run_file_name="runscript.sh"
  else
    declare -r run_file_name="runscript_extended.sh"
  fi

  # Copy
  if [[ $((!has_run || replace_run)) == "1" ]]; then
    subcommand deploy --yes --quiet --copy=true --name=run.sh --file "$dotfiles/snippets/$run_file_name" --dir "$init_path"
    chmod +x "$init_path/run.sh"
  fi
  echok "Done: Initialized runscript at $text_dim$path$text_normal, sourcing $text_dim$dotfiles$text_normal"
}

# TODO Add command_employ as opposite of deploy

# TODO Move this helper to scripts/install/commands.sh (possibly keep
#      a delegator here)
# TODO Option to append 'source ~/dotfiles/.file' to end of an already existing
#      file (better than aborting).
# Deploy a dotfile to a location
command_deploy() {
  set_args "--file= --dir= --copy=false --name --yes --keep --quiet --help" "$@"
  eval "$get_args"

  declare be_quiet="false"
  declare source_file="$file"
  declare target_dir="$dir"
  declare source_name
  source_name="$(basename "$file")"
  declare target_name="$source_name"
  declare make_copy="$copy"
  declare yes_all="false"
  if [[ "$name" != "false" ]]; then target_name="$name"; fi
  if [[ "$yes" == "true" ]]; then yes_all="true"; fi
  if [[ "$quiet" == "true" ]]; then be_quiet="true"; fi

  if [[ "$make_copy" == "false" ]] && [[ ! "${source_file:0:1}" == "/" ]]; then
    if [[ "$be_quiet" == "true" ]]; then
      errchow "Quiet: Better give full paths for symlinking (is: $source_file)"
      return 0
    else
      abort "Better give full paths for symlinking (is: $source_file)"
    fi
  fi

  declare target_file="$target_dir/$target_name"

  # Verify needed stuff is in place
  if [[ ! -f "$source_file" && ! -d "$source_file" ]]; then
    # TODO This if quite then construct is not nice
    if [[ "$be_quiet" == "true" ]]; then
      errchow "Quiet: No regular file $source_file"
      return 0
    else
      abort "No regular file $source_file"
    fi
  fi

  if [[ ! -d "$target_dir" ]]; then
    if [[ "$yes_all" == "true" ]] ||
      [[ "$(boolean_prompt "Create directory $target_dir?")" == "y" ]]; then
      ensure_directory "$target_dir"
    fi
  fi

  # Verify nothing is in the way
  declare preparation=":"
  if [[ -e "$target_file" ]]; then
    if [[ "$keep" == "true" ]]; then
      # shellcheck disable=SC2010
      echos "deployment (keeping existing file)"
      return 0
    fi
    echoi "Target $text_italic$target_dir/$text_bold$target_name$text_normal already exists:"
    # shellcheck disable=SC2010
    errchoi "$(ls -alF "$target_dir" | grep --color=auto -F "$target_name")"
    declare choice="n"
    choice=$(boolean_prompt "Save existing target as $text_italic$target_dir/$text_bold$target_name$text_underline.backup_${text_invert}time$text_normal and replace?")
    if [[ "$choice" == "n" ]]; then
      if [[ "$be_quiet" == "true" ]]; then
        echon "NOT deploying (overwrite denied by user): $source_file ➜ $target_file"
        return 0
      else
        abort "Aborted by user"
      fi
    fi
    # Only rename after all other confirmations
    # shellcheck disable=SC2016
    preparation='mv -v "$target_file" "${target_file}.backup_$(date -Iseconds)"'
  fi

  # Double check
  if [[ ! "$yes_all" == "true" ]]; then
    [[ "$make_copy" == "false" ]] &&
      choice=$(boolean_prompt "Confirm deployment: Create link $target_file → $source_file?") ||
      choice=$(boolean_prompt "Confirm deployment: Copy file $target_file ⇐ $source_file?")
    if [[ "$choice" == "n" ]]; then
      errchon "NOT deploying (denied by user): $source_file ➜ $target_file"
      return 0
    fi
  fi

  # Just do it
  errchol "Deploying $text_italic$source_file$text_normal ➜ ${text_italic}$target_dir/${text_bold}$target_name$text_normal" \
    "$(if [[ "$make_copy" != "false" ]]; then { echo "as copy"; }; else { echo "as link"; }; fi)"
  eval "$preparation"
  if [[ "$make_copy" != "false" ]]; then
    cp -vT "$source_file" "$target_file" || return
  else
    ln --verbose --symbolic -T "$source_file" "$target_file" || return
  fi
  echok "Deployed $text_italic$source_file$text_normal ➜ ${text_italic}$target_dir/${text_bold}$target_name$text_normal"
}

# Import an external file into dotfiles. I.e., move the actual file here, and
# then 'deploy' it to its original location. For now only simple 1-to-1 file
# imports.
command_import() {
  set_args "--from= --to= --copy --dry-run --help" "$@"
  eval "$get_args"

  # Sanity checks
  if [[ ! -d "$to" || ! -e "$to" ]]; then
    abort "Target $to is not a directory"
  fi
  if [[ ! -f "$from" && ! -d "$from" ]]; then
    abort "Expected directory or regular file as source: $from"
  fi
  declare source_name
  source_name="$(basename "$from")"
  declare -r target_path="$to/$source_name"
  declare -r target_path_colour="$text_dim$to/$text_user_soft$source_name$text_normal"
  declare -r from_colour="$text_dim$from$text_normal"
  if [[ -e "$target_path" ]]; then
    abort "Target $target_path already exists"
  fi
  if [[ -d "$from" ]]; then
    declare file
    pushd "$from"
    for file in **/*; do
      if [[ ! -d "$file" && ! -f "$file" ]]; then
        abort "Import files or directories. Neither: $from/$file"
      fi
    done
    popd
  fi

  declare source_dir target_path_full
  source_dir="$(dirname "$from")"
  target_path_full="$(realpath -s "$target_path")"
  show_variable from
  show_variable to
  show_variable source_dir
  show_variable source_name
  show_variable target_path
  show_variable target_path_full
  # abort "Aborting fro testing"

  echol "Importing $from_colour ➜ $target_path_colour" \
    "$(if [[ "$copy" == "true" ]]; then { echo "as copy"; }; else { echo "as link"; }; fi)"
  declare do_command
  if [[ "$dry_run" == "true" ]]; then
    do_command="print_values"
  else
    do_command="print_and_execute"
  fi
  if [[ "$copy" == "true" ]]; then
    "$do_command" cp -vr "$from" "$to"
  else
    "$do_command" mv -v "$from" "$to"
    echo
    "$do_command" subcommand deploy --yes --file="$target_path_full" --dir="$source_dir"
    echo
  fi
  echok "Importing $from_colour ➜ $target_path_colour" \
    "$(if [[ "$copy" == "true" ]]; then { echo "as copy"; }; else { echo "as link"; }; fi)"
}

# Print some basic system information
command_info() {
  set_args "--disk --inet --system --help" "$@"
  eval "$get_args"
  declare -r filename="system_info_txt"

  declare -r info_path="$(create_truncate_tmp "$filename")"
  if [[ "$disk" == "true" ]]; then
    print_and_execute command df -h >>"$info_path"
  fi
  if [[ "$system" == "true" ]]; then
    set +e
    { print_and_execute lsb_release -a || errchow "lsb_release failed"; } >>"$info_path"
    set -e
    { print_and_execute uname -a; } >>"$info_path"
    { print_and_execute lscpu; } >>"$info_path"
  fi
  if [[ "$inet" == "true" ]]; then
    { print_and_execute sudo netstat -ltnp; } >>"$info_path"
    { print_and_execute ifconfig; } >>"$info_path"
  fi

  batcat "$info_path"

  return 0
}

# ╭──────────────────────╮
# │ 🖩 Utils              │
# ╰──────────────────────╯

shutdown_timer() {
  declare -i time="${1:-"60"}"
  { progress_sleep "$time" "⏳   ${text_green}[${text_bg}s${text_normal}${text_green}]hutdown${text_normal} ⏩  ⛔ ${text_red}[${text_br}Enter${text_normal}${text_red}] abort${text_normal}" 20 &&
    shutdown "+0"; } &
  shutdown_pid="$!"
  trap 'kill "$shutdown_pid";shutdown_pid=""; errchos "Cancelled shutdown (press any key)";' SIGINT # TODO Util to ADD to trap, not overwrite it
  echon "shutdown_pid: $shutdown_pid"

  declare user_key
  read -n1 -rs user_key # If nothing happens the timer runs out and shuts down
  if [[ -n "$shutdown_pid" ]]; then
    kill "$shutdown_pid"
  else
    echon "Shutdown timer was interrupted"
  fi

  if [[ -n "$shutdown_pid" ]]; then
    if [[ "$user_key" == "s" ]]; then
      echok "Shutting down"
      { sleep 1 && shutdown "+0"; } & # Wait 1 second to allow bash to close
      return 0
    else
      echos "Cancelled shutdown"
    fi
  fi
}

# This is a helper meant as default additional stuff to be done to update
rebase_on_master_helper() {
  declare branch
  branch="$(git_current_branch)"

  # Sanity check
  if [[ "$branch" == "master" ]]; then
    abort "rebase_on_master_helper: Refusing to rebase master on master"
  fi

  git_fetch_master
  git_rebase_ifneeded "$@"
}

# TODO remove
# shellcheck disable=all
true_colour_old() {

  #!/bin/bash
  #
  #   This file echoes a bunch of 24-bit color codes
  #   to the terminal to demonstrate its functionality.
  #   The foreground escape sequence is ^[38;2;<r>;<g>;<b>m
  #   The background escape sequence is ^[48;2;<r>;<g>;<b>m
  #   <r> <g> <b> range from 0 to 255 inclusive.
  #   The escape sequence ^[0m returns output to default

  setBackgroundColor() {
    echo -en "\x1b[48;2;$1;$2;$3""m"
  }

  resetOutput() {
    echo -en "\x1b[0m\n"
  }

  # Gives a color $1/255 % along HSV
  # Who knows what happens when $1 is outside 0-255
  # Echoes "$red $green $blue" where
  # $red $green and $blue are integers
  # ranging between 0 and 255 inclusive
  rainbowColor() {
    errcho "Rainbow: [$@]"
    let h=$((${1} / 43))
    let f=$1-43*$h
    let t=$f*255/43
    let q=255-t

    if [ $h -eq 0 ]; then
      echo "255 $t 0"
    elif [ $h -eq 1 ]; then
      echo "$q 255 0"
    elif [ $h -eq 2 ]; then
      echo "0 255 $t"
    elif [ $h -eq 3 ]; then
      echo "0 $q 255"
    elif [ $h -eq 4 ]; then
      echo "$t 0 255"
    elif [ $h -eq 5 ]; then
      echo "255 0 $q"
    else
      # execution should never reach here
      echo "0 0 0"
    fi
  }

  for i in $(seq 0 127); do
    setBackgroundColor $i 0 0
    echo -en " "
  done
  resetOutput
  for i in $(seq 255 128); do
    setBackgroundColor $i 0 0
    echo -en " "
  done
  resetOutput

  for i in $(seq 0 127); do
    setBackgroundColor 0 $i 0
    echo -n " "
  done
  resetOutput
  for i in $(seq 255 128); do
    setBackgroundColor 0 $i 0
    echo -n " "
  done
  resetOutput

  for i in $(seq 0 127); do
    setBackgroundColor 0 0 $i
    echo -n " "
  done
  resetOutput
  for i in $(seq 255 128); do
    setBackgroundColor 0 0 $i
    echo -n " "
  done
  resetOutput

  for i in $(seq 0 127); do
    setBackgroundColor $(rainbowColor $i)
    echo -n " "
  done
  resetOutput
  for i in $(seq 255 128); do
    setBackgroundColor $(rainbowColor $i)
    echo -n " "
  done
  resetOutput
}
# ╭──────────────────────╮
# │ 𝑓 Functional         │
# ╰──────────────────────╯
# ╭──────────────────────╮
# │ 🖹 Help strings       │
# ╰──────────────────────╯

declare -r nvim_help_string='Backup or restore nvim config files
SYNOPSIS
  nivm --backup
  nvim --restore
DSCRIPTION
  Commands to move nvim config files when we want to test a fresh LazyVim from
  the LazyVim starter. Only one option can be passed at a time. When called
  without options, only displays the current state.
OPTIONS
  --backup: Move the live config files away. Do not call twice in a row.
  --restore: Move the backup files to live config. Must call --backup beforehand.'

declare -r unun_help_string='Remove undofiles from current directory'

declare -r run_help_string='Ephemeral command for whatever is required at the moment
DESCIPTION
  Better not rely on this command to have any specific effect.'
declare -r test_help_string="Run tests
SYNOPSIS
  test
DESCRIPTION
  Run collection of tests. Tests do not cover everything yet, just some specific
  things. The tests include shellcheck, which is probably most useful
  day-to-day."

# shellcheck disable=SC2016
declare -r alias_help_string='Manage local alias
SYNOPSIS
  1) alias
  2) alias NAME
  3) alias NAME --value="ls $HOME/Downloads/"
  4) alias NAME --delete
DESCRIPTION
  1) Show the current alias entry for NAME.
  2) Create a new alias NAME.
  3) Delete alias NAME.
  Manages aliases in dot/bash_aliases_local. This is meaant for local alises
  that would be misplaced in the regular dot/bash_aliases.sh, but useful on
  a specific machine.
OPTIONS
  --name: Name of the new alias command
  --value: If provided, set alias to this value
  --delete: If provided, delete alias'
declare -r clear_cache_help_string='Clear script cache
SYNOPSIS
  clear_cache
DESCRIPTION
  Remove directory "scripts/.cache/", resetting the cache. All cache uses are
  required to allow the sudden wipe.'

declare -r timer_help_string='Set a timer
SYNOPSIS
  timer MINUTES
  timer MINUTES --message=MESSAGE
  timer SECONDS --unit=s
  timer MINUTES --console
DESCRIPTION
  Notifies with
    - notify-send
    - console message
    - beep sound
  after time duration has passed.
OPTIONS
  --duration=NUMBER: Number of time units to wait for
  --unit={m,s}: Time unit. Minutes/seconds.
  --message=MESSAGE: Message to show after timer is done
  --no-beep: Do not produce a beep ("\a")
  --no-console: Do not print text to console'

declare -r update_alternatives_help_string="Wrap linux util 'update-alternatives'
SYNOPSIS
  (1) update_alternatives [--path=] /usr/bin/gcc-10
  (2) update_alternatives --path=PATH [--name=NAME] [--link=LINK] [--priority=PRIORITY]
  (3) update_alternatives [--path=] WHICH_NAME
DESCRIPTION
  Wraps the linux core-util 'update-alternatives' in a wrapper with our
  arbitrarily-chosen defaults: Unless specified explicitly, --name is derived
  from --path by removing regex '-[0-9]+$' from the end (if possible) and then
  taking the basename. --link is then derived from --name by adding a default
  path. Note: The order or arguments is different from update-alternatives:
  --path goes first (not third).

  tl;dr:
      --path ➜ --name ➜ --link
      --path ➜ --priority

  The easy way (1) is a program path/name-version, i.e.,
      update_alternatives /usr/bin/gcc-10
  generates --name=gcc ➜ --link=$update_alternatives_default_link/gcc.
  If the automatic rules for --link and --name do not apply, simply provide all
  arguments explicitly (2), as required by update-alternatives.
  If --path does not start with '/', the output of \$(which path) is used as
  --path instead (3). This can make it easier to add binaries already accessible
  through \$PATH.
OPTIONS
  --path=pth: Set path to the alternative binary (/usr/bin/gcc-10). When not
    starting with '/', filter through 'which' before using.
  --name=nme: Name, as required by update-alternatives. If not given, trailing
    simple version string is removed from --path and the basename of the result
    is used as name.
  --link=lnk: Link, as required by update-alternatives. If not provided, --name
    is prepended by the default path $text_dim$update_alternatives_default_link$text_normal.
  --priority=prio: Priority, as required by update-alternatives. if not
    provided, the trailing dash-digits of --path (which is removed for --name)
    is used as priority, i.e., gcc-10 gets priority 10.
  --dry-run: Do nothing. Only print what would be done without --dry-run.
  --yes: Do not ask user for confirmation (sudo passwd will still be needed).
    "

declare -r restoration_tarball_help_string="Backup files for machine wipe
SYNOPSIS
  restoration_tarball [--name=NAME] --destination=PATH
  restoration_tarball [--name=NAME] --move=PATH
  restoration_tarball [--name=NAME] --stick [--move]
  restoration_tarball --test_unpacking [--verbose]
DESCRIPTION
  Save the following files into a tarball to simplify restoring some state
  when wiping a machine:
    - Firefox profile
    - Dotfiles (to not have to restore from git)
    - SSH (to not have to replace all keys)
  Adds a script 'restore.sh' that automatically restores the state.

  The backup tarball is esentially a copy of the root directory '/', where
  only the relevant files are present. During extraction, the tarball is first
  extracted to a subdirectory of /tmp, then moved to '/', replacing existing
  file swith the same name.

  ❕ It is not advisable to restore into a running system.

OPTIONS
  --name=NAME: Begin backup filenames with NAME.
  --destination=PATH: Save backup to PATH. Default: $restoration_default_destination
  --move=MOVE_PATH: Move backup directory as a whole to MOVE_PATH. The backup
    is first created in --destination (can remain default) and then moved to
    MOVE_PATH. Use this to avoid fragments when the restoration process fails.
  --stick: If present, overwrite --destination  with the predefined path
        '$restoration_stick_path',
    where we expect a USB stick to be located. When --move is given, replace
    the --move path instead of the --destination path. This option is for
    convenience so that common paths must not be remembered.
  --test_unpacking: Test unpacking of backup tarball. For debugging.
    ❕ This does NOT use the restoration scrip, merely the tarball is
       extracted to see if its content is as expected.
  --verbose: Add -v flag to tar when creating backup.
  --help: Show this help."

declare -r wipe_cache_help_string="Delete cache directory
  DESCRIPTION
    By construction, all uses of the cache directory should be fine with losing
    all entries (in-between uses), so this operation should always be safe.
    Although it may cause processes using the cache directory to repeat
    computation.
  OPTIONS
    --help: Show this help."

declare -r upgrade_help_string="Upgrade apt/snap packages
DESCRIPTION
  Upgrades apt and snap packages.
  Upgrades only once per day if --daily is given.
OPTIONS
  --daily: Ignore when called fo rthe second time on any given day.
  --with-new-pkgs: Run an additional pass with --with-new-pkgs when doing 'apt
                   upgrade'."

declare -r shutdown_upgrade_help_string="Do daily apt upgrades and shutdown after 1 minute
DESCRIPTION
  Used the scripts cache util to query upgrades only once per day (or after
  cache wipe).
OPTIONS
  --timer=SECONDS: Set the timer to shut-down to SECONDS seconds. Default 60."

declare -r update_dotfiles_branch_help_string=$'Update dotfiles git branch from origin
\nThis command is meant to be individualized when a git branch is meant to, for example, be rebased on master or merging master continuously.'

declare -r colours_help_string=$'Demonstrate terminal colour capabilities.
\nUseful for: checking colour codes or testing which colours are supported.
See scripts/test/run.sh for implementation'

declare -r termcaps_manpage_help_string=$'Show terminal capability man page'

declare -r install_help_string="Delegates to: 'scripts/install/ default'

  DESCRIPTION

    Delegates execution to scripts/install/run.sh default command. This includes
    remaining arguments, so the defaultcommand can be parametrized:

        install --help

    (The install script doesnt take any arguments at the moment)."

declare -r init_runscript_help_string="Initialize default runscript at some directory
SYNOPSIS
  init_runscript PATH [--extended]
  init_runscript PATH --standalone
DESCRIPTION
  Initialize runscript at PATH (if given) or working directory (else). Creates
  a copy of the runscript snippet at location PATH.
  In the first for, uses the current \$dotfiles as set by the invoking runscript
  as source for the snippet. The new runscript will source the same \$dotfiles.
  In the second form, uses command 'export_dotfiles_scripts_standalone' to copy
  dotfiles to PATH/. The new dotfiles them initialize as requested. The new
  runscript will work with the copied dotfiles directory.
OPTIONS
  --path=PATH: Initialize runscript at this path (defaults to working directory
    of caller).
  --extended=false: Initialize from extended template. Default false.
  --standalone: Create self-contained system by copying all dependenies into
    PATH/. See: export_dotfiles_scripts_standalone --help.
  --confirm: Confirm PATH before continuing.
  --yes: Passed to export_dotfiles_standalone when --standalone is used."

declare -r export_dotfiles_scripts_standalone_help_string="Export standalone copy of dotfiles scripts
SYNOPSIS
  export_dotfiles_scripts_standalone --path=PATH [--name=NAME]
    ➜ new_dotfiles_directory_path
DESCRIPTION
  Output: Path to the newly created directory. If provided a full path, this
  path will be a full path as well.

  This command is useful if you want to export a project using the default
  runscipt commands, but the users are not using our dotfiles. This command will
  provide copies of many scripts, you can manually remove files that are not
  required for the particular use case.

  The dotfiles varialbe in the run_script file is modified to point at the
  copied location. It can be immediately used to init_runscript further links to
  the dotfiles copies. Use the returned path to do so.

  Only the default runscript of the copy is initialized. Use it to initialize
  other runscripts that you might create (or already have) in your project.

OPTIONS
  --path: Parent path to place the dotfiles in. This could just be the project
    directory, so the dotfiles copy is placed next to the runscript.
  --name: Name of the copy of the dotfiles directory. Defaults to dotfiles_copy.
  --yes: Do not prompt when exporting non-master branch. For testing."

declare -r deploy_help_string="Copy or symlink dotfile to a specified location
SYNOPSIS
  deploy --help
  deploy --file=FILE --dir=DIR [--copy=false] [--name=NAME] [--yes]
DESCRIPTION
  Deploy dotfile ${text_bold}FILE${text_normal} to directory ${text_bold}DIR${text_normal} by symlink (by copy if --copy is given).
  ${text_bold}FILE${text_normal}: Source dotfile to be deployed.
  ${text_bold}DIR${text_normal}:  Target directory to place the link (or copy) in.
OPTIONS
  --file=FILE: Dotfile or directory to be deployed.
  --dir=DIR: Target directory to place the link (or copy) into.
  --name=NAME: Create symlink (or copy) with name NAME.
    If not present, NAME equals the name of the dotfile.
  --copy=false: Set to 'true' to create copy instead of symlink (default false).
  --yes: If present, skip confirmation prompt when no problem occurs.
  --quiet: Return 0 when user rejects replacing an existing file. Normally
    returns nonzero"

declare -r import_help_string='Import a file/directory as new dotfile
SYNOPSIS
  import --from=SOURCE --to=TARGET_DIR [--copy]
DESCRIPTION
  Reverse of "deploy". Move a file or directory (into dotfiles). At its original
  location, place a symlink to the new location.

  Meant for manual use. You may want to rename the moved files afterwards. Or
  delete some of the contained files (if it is a directory).
OPTIONS
  --from=SOURCE: Source file or directory to be imported.
  --to=TARGET_DIR: Target directory to move the imported file to.
  --copy: Re-deploy as a copy instead of a symlink (default false).
          ❓ Does this work with both files and directories?
  --dry-run: Only print what would happen. Do not move/copy.'

declare -r info_help_string='Print system information
DESCRIPTION
  Executes various typical commands to obtain information. Makes it so that the
  commands need not be remembered.
SYNOPSIS
  info --disk --inet --system
OPTIONS:
  --disk: Disk space.
  --inet: Internet connections.
  --system: Operating system and hardware.'

# ╭──────────────────────╮
# │ ⚙ Boilerplate        │
# ╰──────────────────────╯

# Transition to provided command
subcommand "${@}"
# ╭──────────────────────╮
# │ 🕮  Documentation     │ ✖️ No documentation
# ╰──────────────────────╯
