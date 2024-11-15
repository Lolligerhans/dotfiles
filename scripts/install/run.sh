#!/usr/bin/env bash

# version 0.0.0

# shellcheck disable=2120,2145

declare -gr dotfiles="${DOTFILES:-"$HOME/dotfiles"}" # TOKEN_DOTFILES_GLOBAL
declare -gA _sourced_files=(["runscript"]="")
#declare -ga this_location="";
source "$dotfiles/scripts/boilerplate.sh" "${BASH_SOURCE[0]}" "$@"
satisfy_version "$dotfiles/scripts/boilerplate.sh" "0.0.0"

# ┌────────────────────────┐
# │ Info                   │
# └────────────────────────┘

# Subroutines to install modules. Called in bulk by the top level install
# script, but can also be invoked individually from here.

# ┌────────────────────────┐
# │ Config                 │
# └────────────────────────┘
_run_config["versioning"]=0
_run_config["log_loads"]=0
#["error_frames"]=2 # [1,inf)

# ┌────────────────────────┐
# │ Includes               │
# └────────────────────────┘

# FIXME ensure version without include
#ensure_version "$dotfiles/run.sh" 0.0.0;

load_version workspace.sh 0.0.0 # Helpers for the setup of topic-based workspaces.
load_version "$dotfiles/scripts/progress_bar.sh" 0.0.0

# Ensuring version even if included already
load_version "$dotfiles/scripts/version.sh" 0.0.0
#load_version "$dotfiles/scripts/assert.sh" 0.0.0;
load_version "$dotfiles/scripts/bash_meta.sh" 0.0.0
#load_version "$dotfiles/scripts/boilerplate.sh" 0.0.0;
load_version "$dotfiles/scripts/cache.sh" 0.0.0
#load_version "$dotfiles/scripts/error_handling.sh" 0.0.0;
load_version "$dotfiles/scripts/fileinteracts.sh" 0.0.0
#load_version "$dotfiles/scripts/git_utils.sh" 0.0.0;
load_version "$dotfiles/scripts/setargs.sh" 0.0.0
load_version "$dotfiles/scripts/termcap.sh" 0.0.0
load_version "$dotfiles/scripts/userinteracts.sh" "0.0.0"
load_version "$dotfiles/scripts/utils.sh" 0.0.0

# shellcheck source-path=scripts/install
source "install.sh" # Individual install subroutines
# shellcheck source-path=scripts/install
source "symlink.sh" # Individual symlink subroutines

# ┌────────────────────────┐
# │ Constants              │
# └────────────────────────┘

# Installation stdout/stderr is written here
declare -r logfile="log/install.log"
: >"$logfile"

# TODO Create global array with paths of dotfiles? Just for install runscript?
declare -r completion_path="$dotfiles/dot/bash_completion"
# Ansers HTTP 404
#declare -r git_diff_hl_url="https://raw.githubusercontent.com/git/git/master/contrib/diff-highlight/diff-highlight";
declare -r default_workspace_name="example"

# ┌────────────────────────┐
# │ Commands               │
# └────────────────────────┘

command_default() {
  set_args "--force --help" "$@"
  eval "$get_args"

  declare all_ok="false"
  subcommand add_credentials all_ok
  if [[ "$force" == "false" && "$all_ok" == "false" ]]; then
    abort "Use $0 default --force to ignore credentials check."
  fi
  subcommand full_install
}

command_full_install() {
  set_args "--help" "$@"
  eval "$get_args"

  declare choice="n"
  choice="$(boolean_prompt "Install now?")"
  if [[ "$choice" == "n" ]]; then
    abort "Aborted by user"
  fi
  subcommand install_collected_apt
  echo
  subcommand symlink --all
  subcommand generate_ssh_keypairs --silent
  subcommand install_missing_term_readkey --yes
  subcommand install --all
  subcommand show_manual

  echo
  echok "Full installation done!"
  echo
}

# TODO: Move other commands install_xyz to install.sh and call them from here
command_install() {
  set_args "--help --all \
    --diff-highlight \
    --difftastic \
    --fzf \
    --jetbrains-mono-nerdfont \
    --mcfly \
    --mpk \
    --nvim \
    --tree-sitter \
    --vundle \
    " "$@"
  eval "$get_args"

  declare -Ar install_functions=(
    ["diff_highlight"]="install_diff_highlight"
    ["difftastic"]="install_difftastic"
    ["fzf"]="install_fzf"
    ["jetbrains_mono_nerdfont"]="install_jetbrains_mono_nerdfont"
    ["mcfly"]="install_mcfly"
    ["mpk"]="install_mpk"
    ["nvim"]="install_nvim"
    ["tree_sitter"]="install_tree_sitter"
    ["vundle"]="install_vundle"
  )

  declare arg="" func=""
  declare -i exit_code
  for arg in "${!install_functions[@]}"; do
    declare -n _arg="$arg" # Reference the variable created by set_args.
    if [[ "$all" == "true" || "$_arg" == "true" ]]; then
      func="${install_functions[$arg]}"
      {
        may_fail exit_code -- "$func"
      } &>>"${logfile}"
      if ((0 == exit_code)); then
        echok "Install ok: ${arg//_/-}" | tee -a "$logfile"
      else
        echow "Install failed: ${arg//_/-}" | tee -a "$logfile"
      fi
    fi
  done
}

command_symlink() {
  set_args "--help --all \
    --bash-aliases \
    --bash-completion \
    --bash-gitcompletion \
    --bashrc \
    --ctags \
    --gdbinit \
    --gitconfig \
    --gitignore-global \
    --iftoprc \
    --inputrc \
    --neovim \
    --ripgrep-config \
    --shellcheckrc \
    --ssh-config \
    --toprc \
    --vim-operatorhighlight \
    --vim-ftplugin \
    --vimrc \
    --vundle \
    " "$@"
  eval "$get_args"

  declare -Ar symlink_functions=(
    ["bash_aliases"]="symlink_bash_aliases"
    ["bash_completion"]="symlink_bash_completion"
    ["bash_gitcompletion"]="symlink_bash_gitcompletion"
    ["bashrc"]="symlink_bashrc"
    ["ctags"]="symlink_uctags"
    ["ctags"]="symlink_ectags"
    ["gdbinit"]="symlink_gdbinit"
    ["gitconfig"]="symlink_gitconfig"
    ["gitignore_global"]="symlink_gitignore_global"
    ["iftoprc"]="symlink_iftoprc"
    ["inputrc"]="symlink_inputrc"
    ["neovim"]="symlink_neovim"
    ["ripgrep_config"]="symlink_ripgrep_config"
    ["shellcheckrc"]="symlink_shellcheck_config"
    ["ssh_config"]="symlink_ssh_config"
    ["toprc"]="symlink_toprc"
    ["vim_operatorhighlight"]="symlink_vim_operatorhighlight"
    ["vim_ftplugin"]="symlink_vim_ftplugin"
    ["vimrc"]="symlink_vimrc"
  )

  declare arg="" func=""
  declare -i exit_code
  for arg in "${!symlink_functions[@]}"; do
    declare -n _arg="$arg" # Reference the variable created by set_args.
    if [[ "$all" == "true" || "$_arg" == "true" ]]; then
      func="${symlink_functions["$arg"]}"
      {
        may_fail exit_code -- "$func"
      } &>>"${logfile}"
      if ((0 == exit_code)); then
        echok "Symlink ok: ${arg//_/-}" | tee -a "$logfile"
      else
        echow "Symlink failed: ${arg//_/-}" | tee -a "$logfile"
      fi
    fi
  done
}

command_add_credentials() {
  set_args "--ret= --help" "$@"
  eval "$get_args"

  declare -n _ret_13048749814="$ret"
  _ret_13048749814="false"
  declare _all_ok_973418034="true"

  # Insert the unquote-quote so this line does not match the token
  if grep --exclude-dir=.git/ -RF "TOKEN_""DOTFILES_USER_CREDENTIALS" "$dotfiles"; then
    echou "Add your credentials at 'DOTFILES_USER_CREDENTIALS'"
    _all_ok_973418034="false"
  else
    echos "DOTFILES_USER_CREDENTIALS: All done"
  fi

  if grep --exclude-dir=.git/ -RF "TOKEN_""DOTFILES_WORKSPACE_PREPARATIONS"; then
    echou "Prepare a workspace at 'DOTFILES_WORKSPACE_PREPARATIONS'"
    _all_ok_973418034="false"
  else
    echos "DOTFILES_WORKSPACE_PREPARATIONS: All done"
  fi

  if grep --exclude-dir=.git/ -RF "TOKEN_""DOTFILES_BRANCH_PREPARATIONS"; then
    echou "Prepare a new branch at 'DOTFILES_BRANCH_PREPARATIONS'"
    _all_ok_973418034="false"
  else
    echos "DOTFILES_BRANCH_PREPARATIONS: All done"
  fi

  if [[ "$_all_ok_973418034" == "true" ]]; then
    _ret_13048749814="true"
  fi
}

command_workspace() {
  set_args "--name=$default_workspace_name --list --help" "$@"
  eval "$get_args"

  if [[ "$list" == "true" ]]; then
    workspace_list
    return 0
  fi

  # Call helper function from workspace.sh. Must make sure that such a worksapce
  # name actually exists.
  declare -r funcname="prepare_${name}_workspace"
  if ! declare -F "$funcname" >/dev/null; then
    echon "You can add workplaces by adding the function $funcname to workspace.sh"
    abort "Workspace $text_bold${name}$text_normal does not exist"
  fi
  "prepare_${name}_workspace" # Function in workspace.sh must be named accordingly
  echok "Prepared workspace $text_user_soft${name}$text_normal"
}

command_show_manual() {
  echou "Manual: Terminal colours..."
  grep -e "terminal-bold" "$dotfiles/data/colours.txt" || true
  echou "Manual: (Re-)use old firefox profile (when restored from tarball): visit 'about:profiles'. You might need to sudo snap refresh firefox to get newest version."
}

command_install_nala_legacy() {
  errchof "I think nala legacy build was broken last time I tried"
  if ! [[ "$(ask_user "Continue?")" == "true" ]]; then abort "Aborted by user"; fi

  declare -r base_dir=~"/github"
  declare -r nala_dir="$base_dir/nala"
  if [[ -d ~/github/nala ]]; then abort "Directory $nala_dir already exists"; fi

  # Install nala from source as legacy support for Ubuntu 20
  errchol "Installing nala dependencies..."
  sudo apt-get install -y wget build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev libbz2-dev

  errchol "Downloading nala dource code..."
  ensure_directory "$base_dir"
  pushd "$base_dir"
  git clone https://gitlab.com/volian/nala.git
  pushd nala/

  errchol "Building legacy version"
  sudo make legacy
  #sudo make legacy-update to update

  errchok "Installed: nala legacy"
  popd
  popd
}

command_install_missing_term_readkey() {
  # TODO: Check for existing installation
  declare confirm="false"
  set_args "--yes" "$@"
  eval "$get_args"
  [[ "$yes" == "true" ]] && confirm="true"

  # Fix git warning missing term::readkey for interactive add
  errchol "${FUNCNAME[0]}: Trying to fix missing Term::ReadKey"
  apt-cache search term.*readkey
  if [[ "$confirm" == "true" ]] || [[ "$(ask_user "Install libterm-readkey-perl?")" == "true" ]]; then
    sudo apt install libterm-readkey-perl
  else
    errchol "${FUNCNAME[0]}: declined"
  fi
}

command_install_collected_apt() {
  # TODO: check for existing installation
  declare -r cache_key="install_apt"
  declare upgrade_needed
  upgrade_needed="$(cache_daily "$cache_key" "get")"
  if [[ "$upgrade_needed" == "false" ]]; then
    echos "(daily) apt upgrade"
    return 0
  fi

  # This function install different utilities that can be easily loaded by apt
  # or any other external system.
  echol "Installing collected apt packages..."
  # shellcheck disable=SC2015
  {
    #declare ubuntu_version;
    #ubuntu_version="$(lsb_release -rs)";
    #{
    #  # Allow vim 9 on ubuntu
    #  sudo add-apt-repository -y ppa:jonathonf/vim &&
    #  sudo apt install vim;
    #} || {
    #  echow "Installing vim-9 failed. Falling back to vim-gtk3";
    #  sudo apt install vim-gtk3;
    #} || echoe "Installing vim failed (apt)";

    sudo apt install \
      git \
      python3-venv \
      bat \
      ripgrep \
      xclip \
      net-tools \
      curl \
      iftop \
      shellcheck \
      git-delta \
      npm ||
      echoe "Installing apt packages failed"

    {
      # Need new firefox, else our profile backup could be too new
      declare prg
      for prg in universal-ctags snap firefox; do
        sudo snap info "$prg" &&
          sudo snap install "$prg" &&
          sudo snap refresh "$prg"
      done
    } || echoe "Installing snap packages failed"
    cache_daily "$cache_key" "set" >/dev/null
  } &&
    echok "Done: Installing collected/snap apt packages" ||
    errchoe "${FUNCNAME[0]}: Failed to install from packet managers"
}

command_install_cpan() {
  # CPAN is from perl and does the git interactive immediate key presses
  sudo cpan Term::ReadKey
}

command_generate_ssh_keypairs() {
  # TOKEN_DOTFILES_USER_CREDENTIALS
  #generate_single_ssh_keypair --silent -f=id_example -C="Example.Name@emal.com";
  #generate_single_ssh_keypair --silent -f=id_alias -C="AnotherAlias";
  abort "Unavailable (add credentials or remove this line)"
  errchol "Done: Creating ssh key pairs"
}

# Download IDEA and unpack tarball to ~/Downloads/idea-IDE. This path matches
# the change we make to PATH in our bashrc_personal.
command_install_idea() {
  set_args "--help" "$@"
  eval "$get_args"

  declare -r filename="ideaIC-2023.3.3.tar.gz"
  declare -r direct_link="https://download.jetbrains.com/idea/${filename}"
  pushd "$HOME/Downloads"
  wget -c "$direct_link"
  sha256sum -c <<<"dc123ded3c7ede89e7cd3d4d5e46fada96b8763f648cd0cdbc5b7d6e26203fd2 ideaIC-2023.3.3.tar.gz"
  declare -r dir_name="idea-IDE" # Used in $dotfiles/dot/bashrc_personal
  ensure_directory "$dir_name"
  tar -xzf "${filename}" -C "$dir_name" --strip-components=1
  popd
}

command_load_font() {
  set_args "--help --zip=" "$@"
  eval "$get_args"

  # Sanity check
  if [[ "${zip}" != *.zip ]]; then
    abort "Not a zip file: ${zip}"
  fi
  ensure_directory "$HOME/.local/share/fonts"

  echol "Installing $text_user$zip$text_normal"

  # Extract
  declare dir
  dir="$(command mktemp -d -t font-XXXXXX)"
  command unzip -d "$dir" "$zip" &>>"$logfile"

  # Install
  declare -a files
  files=("$dir"/*.ttf)
  command mv -v "${files[@]}" ~/.local/share/fonts &>>"$logfile"
  echok $"Installed font $text_user$zip$text_normal"
}

# ┌────────────────────────┐
# │ Helpers                │
# └────────────────────────┘

generate_single_ssh_keypair() {
  # Using the same parameter names as ssh-keygen
  set_args "-f= -t=ed25519 -C --silent" "$@"
  eval "$get_args"

  declare type="$t"
  declare file="$f"

  declare comment=""
  # FIXME I think this _C and $C stuff does not work as intended
  [[ "$C" != "false" ]] && comment="-C $C"

  # TODO Use $silent?

  # Dont overwrite
  if [[ -e ~/.ssh/"$file" ]] || [[ -e ~/.ssh/"$file".pub ]]; then
    if [[ "$silent" == "true" ]]; then
      errchos "[ssh-keypair exists already] generating ssh keypair {$@}"
      return 0
    else
      abort "File already exists: $file or $file.pub"
    fi
  fi

  pushd ~/.ssh/
  errchoi "Creating ssh key pair [$@]"
  # shellcheck disable=SC2086
  ssh-keygen -N "" -t "$type" -f "$file" $comment # Split words in $comment
  # shellcheck disable=SC2010
  ls -alF | grep --color=auto -F "$file"
  popd
}

# ┌────────────────────────┐
# │ Help strings           │
# └────────────────────────┘

declare -r default_help_string="Install dotfiles for current user
DESCRIPTION
  Runs full installation, if credential check succeeds.
  Installation includes
    • apt/snap update
    • symlinking config files from dot/
    • generating ssh keypairs
    • installing software
      ◦ from apt/snap
      ◦ difftastic
      ◦ diff-highlight
    • minor adjustmetns
      ◦ term::readkey fix
      ◦ manual actions
OPTIONS
  --force: Skip credentials check. Dotfile smight not work correctly."
declare -r full_install_help_string="Install (almost) everything
DESCRIPTION
  Installs things that are small and we likely want. Some larger things must be
  added by their own commands (e.g., idea-IDE).
  Does no run add_credentials beforehand, unlile the default command."
declare -r install_help_string="Install components (incomplete)
SYNOPSIS
  install --help
  install [--target, ...]
DESCRIPTION
  Install individual components by specifying them as --argument(s). Targets are
  executed in unspecified order.
  Returns with success even if installation fails. Check output for errors.
OPTIONS
  --all: Install all selectable options
  [--target]: Target to be installed. Use --help to get a list.":
# shellcheck disable=SC2155,SC1070
declare -r install_idea_help_string="Install IDEA
DESCRIPTION
  Download and unpack tarball to ~/Downloads/idea-IDE. This path matches the
  change we make to PATH in our bashrc_personal."
declare -r load_font_help_string="Load zipped font
SYNOPSIS
  load_font --zip=ZIP_FILE
DESCRIPTION
  Extract zip and copy all contained .ttf files to .local/share/fonts. A list of
  copied files can be found in the logfile."
declare -r symlink_help_string="Symlink files
SYNOPSIS
  symlink --all
  symlink --which [--more, ...]
DESCRIPTION
  Symlink predefined targets to their predefined locations. The exact actions
  are specified by the functions in 'symlink.sh'. Typically, lready existing
  files are not replaced.
  In the first version, symlink all predefined targets.
  In the second version, symlink only the specified targets.
OPTIONS
  --all: Symlink all targets.
  --TARGET: Symlink the specified TARGET (hardcoded parameters)."
# shellcheck disable=SC1070,SC1079,SC1078
declare -r add_credentials_help_string="List places where to add credentials
DESCRIPTION
  Greps for TOKEN_""DOTFILES_USER_CREDENTIALS token, which identifies the lines
  where to add user credentials.

  The default commands runs add_credentials by default."
declare -r workspace_help_string="Setup/Download workspaces for given use case
DESCRIPTION
  Prepare workspaces for given use case. Preparation could entail simple git
  cloning, runscript linking, compiling, or other preparations. The workspace
  command is meant to speedup the process of starting on a fresh machine, or
  moving to a different project on an existing machine.
SYNOPSIS
  workspace --help
  workspace --list
  workspace --name=NAME
OPTIONS
  --name=NAME: Select NAME as the workspace to be loaded. Default:
    $default_workspace_name. See --list for available names.
  --list: List all available workspaces. Does not actuall load a workspace
    (effectively overrides --name).
NOTE
  Workspace names should only contain [a-zA-Z] because we grep for the
  corresponding function name."

# Transition to provided command
subcommand "${@}"

# Copy the logfile to /tmp if we want to check it later.
declare -r log_dir="log/"
declare logfile_permanent
logfile_permanent="$log_dir/$(date_nocolon).log"
declare -r logfile_permanent
1>&2 show_variable log_dir
1>&2 ensure_directory "$log_dir"
1>&2 cp "$logfile" "$logfile_permanent"
