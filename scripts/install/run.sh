#!/usr/bin/env bash

# version 0.0.0

# shellcheck disable=2120,2145

declare -gr dotfiles="${DOTFILES:-"$HOME/dotfiles"}"; # TOKEN_DOTFILES_GLOBAL
declare -gA _sourced_files=( ["runscript"]="" );
#declare -ga this_location="";
source "$dotfiles/scripts/boilerplate.sh" "${BASH_SOURCE}" "$@";
satisfy_version "$dotfiles/scripts/boilerplate.sh" "0.0.0";

# ┌────────────────────────┐
# │ Info                   │
# └────────────────────────┘

# Subroutines to install modules. Called in bulk by the top level install
# script, but can also be invoked individually from here.

# ┌────────────────────────┐
# │ Config                 │
# └────────────────────────┘
_run_config["versioning"]=0;
_run_config["log_loads"]=0;
#["error_frames"]=2 # [1,inf)

# ┌────────────────────────┐
# │ Includes               │
# └────────────────────────┘

# FIXME ensure version without include
#ensure_version "$dotfiles/run.sh" 0.0.0;

load_version workspace.sh 0.0.0; # Helpers for the setup of topic-based workspaces.
load_version "$dotfiles/scripts/progress_bar.sh" 0.0.0;

# Ensuring version even if included already
load_version "$dotfiles/scripts/version.sh" 0.0.0;
#load_version "$dotfiles/scripts/assert.sh" 0.0.0;
#load_version "$dotfiles/scripts/boilerplate.sh" 0.0.0;
#load_version "$dotfiles/scripts/cache.sh" 0.0.0;
#load_version "$dotfiles/scripts/error_handling.sh" 0.0.0;
load_version "$dotfiles/scripts/fileinteracts.sh" 0.0.0;
#load_version "$dotfiles/scripts/git_utils.sh" 0.0.0;
load_version "$dotfiles/scripts/setargs.sh" 0.0.0;
load_version "$dotfiles/scripts/termcap.sh" 0.0.0;
load_version "$dotfiles/scripts/userinteracts.sh" "0.0.0";
load_version "$dotfiles/scripts/utils.sh" 0.0.0;

source install.sh; # Individual install subroutines

# ┌────────────────────────┐
# │ Constants              │
# └────────────────────────┘

# TODO Create global array with paths of dotfiles? Just for install runscript?
declare -r completion_path="$dotfiles/dot/bash_completion";
# Ansers HTTP 404
#declare -r git_diff_hl_url="https://raw.githubusercontent.com/git/git/master/contrib/diff-highlight/diff-highlight";
declare -r default_workspace_name="example";

# ┌────────────────────────┐
# │ Commands               │
# └────────────────────────┘

command_default()
{
  set_args "--force --help" "$@";
  eval "$get_args";

  errchof "$FUNCNAME is still untested";

  declare all_ok="false";
  subcommand add_credentials all_ok;
  if [[ "$force" == "false" && "$all_ok" == "false" ]]; then
    abort "Use $0 default --force to ignore credentials check.";
  fi
  subcommand full_install;
}

# TODO Move commands install_xyz to install.sh and call them from here
command_install()
{
  set_args "--help --fzf --mcfly --nvim" "$@";
  eval "$get_args";

  # Maps the --parameter name to internal function. We filter parameters not
  # describing an install target (like --help) by setting a NOP as their
  # function. Then their value does not matter.
  declare -Ar install_functions=(
      ["help"]=":"
      ["fzf"]="install_fzf"
      ["mcfly"]="install_mcfly"
      ["nvim"]="install_nvim"
      );

  declare arg="" func="";
  for arg in "${!install_functions[@]}"; do
    declare -n _arg="$arg"; # Reference the variable created by set_args.
    if [[ "$_arg" == "true" ]]; then
      func="${install_functions[$arg]}";
      "$func" || errchow "Failed to install $arg";
      # Continue after errors. User must check output.
    fi
  done
}

command_full_install()
{
  declare choice="n";
  choice="$(boolean_prompt "Install dotfiles?")";
  if [[ "$choice" == "n" ]]; then
    abort "Aborted by user";
  fi
  subcommand install_collected_apt; echo;
  subcommand symlink_dotfiles; echo;
  subcommand install_difftastic; echo;
  subcommand install_diff_highlight; echo;
  subcommand generate_ssh_keypairs --silent; echo;
  subcommand install_missing_term_readkey --yes; echo;
  subcommand install --fzf; echo;
  subcommand install --mcfly; echo;
  subcommand install --nvim; echo;
  subcommand show_manual; echo;
  echok "Full installation done!";
}

command_symlink_dotfiles()
{
  set_args "--user --help" "$@";
  eval "$get_args";

  ################################################################

  # Preparation

  # FIXME use $dotfiles
  errchot "Replace dotfiles_dir variable with dotfiles variable from runscript";
  declare user_name;
  if [[ "$user" != "false" ]]; then
    user_name="$user";
  else
    user_name="$(whoami)";
  fi
  readonly user_name;
  readonly home_dir="/home/$user_name";
  readonly dotfiles_dir="$home_dir/dotfiles"
  echoi "user_name=$text_user$user_name$text_normal";
  echoi "home_dir=$home_dir";
  echoi "dotfiles_dir=$dotfiles_dir";

  cd "$dotfiles_dir";
  pwd;

  ################################################################

  # separate installation of each dotfile

  # promt starting message
  echo "Installing components:"
  echo

  # install vundle
  echo "Vundle..."
  if [ -d "$home_dir/.vim/bundle/Vundle.vim" ]; then
      echo "skip"
      echo
  else
      echo "installing..."
      git clone "https://github.com/VundleVim/Vundle.vim.git" "$home_dir/.vim/bundle/Vundle.vim" &&
      echo "Removing .git file from Vundle" &&
      rm -rfv "$home_dir/.vim/bundle/Vundle.vim/.git"
      echo "done"
      echo
  fi

  # install vimrc
  subcommand run "$dotfiles" deploy --name=".vimrc" --yes --keep --file="$dotfiles/dot/vimrc" --dir="$home_dir" || :;
  echo

  # install init.vim for neovim
  subcommand run "$dotfiles" deploy --yes --keep --file="$dotfiles/dot/init.vim" --dir="$home_dir/.config/nvim" || :;
  echo

  # Instll .vim/ftplugin files
  subcommand run "$dotfiles" deploy --yes --keep --file="$dotfiles/dot/ftplugin" --dir="$home_dir/.vim" || :;
  echo

  # install .ctags
  subcommand run "$dotfiles" deploy --name=".ctags" --yes --keep --file="$dotfiles/dot/ctags" --dir="$home_dir" || :;
  echo ".ctags ..."
  path="$home_dir/"
  file=".ctags"
  if [ -f "$path/$file" ]; then
    echo "skip"
  else
    echo "installing..."
    ln -s "$dotfiles_dir/.ctags" "$path/$file" &&
    echo "done"
  fi
  echo

  # install wombat colorscheme for vim
#  if false; then
#      echo "wombat (vim colorscheme)"
      #if [ -d "$dotfiles_dir/.vim/
#      echo "Installing wombat colorscheme for vim"
#      git clone "https://github.com/vim-scripts/wombat256.vim.git" &&
#      echo "Removing .git from wombat"
#      rm -rf "${dotfiles_dir:?}/"
      # TODO lol watch out this is dotfiles dir
#  fi

  # use .bashrc_aliases
  path="$home_dir/.bash_aliases"
  echo "bash_aliases..."
  if [ -f "$path" ]; then
      echo "skip"
  else
      echo "installing..."
      ln -v -s "$dotfiles_dir/dot/bash_aliases" "$path" &&
      echo "done"
  fi
  echo

  # use ssh_config
  subcommand rundir "$dotfiles" deploy --name="config" --keep --yes --file="$dotfiles/dot/ssh_config" --dir="${home_dir}/.ssh/" || :;
  chmod 600 ~/.ssh/config;
  echo

  # use .gitconfig
  subcommand run "$dotfiles" deploy --name=".gitconfig" --yes --keep --file="$dotfiles/dot/gitconfig" --dir="$home_dir" || :;
  echo

  # Use gitignore_global
  subcommand run "$dotfiles" deploy --name=".gitignore_global" --yes --keep --file="$dotfiles/dot/gitignore_global" --dir="$home_dir" || :;
  echo;

  # use .bashrc_personal
  # FIXME This is scuffed
  declare -r brcp="$home_dir/.bashrc"
  declare -r brcl="source ~/dotfiles/dot/bashrc_personal; # Must be last line"
  echo "bashrc_personal..."
  if [ ! -f "$brcp" ]; then
      echo "creating file..."
      touch "$brcp"
  else
      echo "(file exists)"
  fi
  last="$(tail -n1 "$brcp")"
  if [[ $last == "$brcl" ]]; then
      echo "skip"
  else
      echo "installing..."
      echo "$brcl" >> "$brcp" &&
      echo "done"
  fi
  echo

  # Plant our own gdbinit
  source_path="gdbinit";
  target_path="$home_dir/.gdbinit";
  echo "gdbinit...";
  if [[ "$(create_if_missing "$target_path")" == "1" ]]; then
    echo "installing...";
    cat "$source_path" >> "$target_path" &&
    echo "done";
  else
    echo "skip";
  fi
  echo

  # Install alias completion
  subcommand rundir "$dotfiles" deploy --name=".bash_completion" --yes --keep --file="$completion_path" --dir="$home_dir" || :; # TODO print warning here?
  echo;

  # Completion options
  ~/dotfiles/run.sh deploy --name=".inputrc" --yes --keep --file="$dotfiles_dir/dot/inputrc" --dir="$home_dir" || :;
  echo

  # Iftop config (.iftoprc)
  ~/dotfiles/run.sh deploy --yes --name=".iftoprc" --yes --keep --file="$dotfiles_dir/dot/iftoprc" --dir="$home_dir" || :;
  echo

  errchok "Command $FUNCNAME done!";
}

command_add_credentials()
{
  set_args "--ret= --help" "$@";
  eval "$get_args";

  declare -n _ret_13048749814="$ret";
  _ret_13048749814="false";
  declare all_ok="true";

  # Insert the unquote-quote so this line does not match the token
  if ! grep -RF "TOKEN_""DOTFILES_USER_CREDENTIALS" "$dotfiles"; then
    echos "DOTFILES_USER_CREDENTIALS: All done";
  else
    echou "Add your credentials at 'DOTFILES_USER_CREDENTIALS'";
    all_ok="false";
  fi

  if ! grep -RF "TOKEN_""DOTFILES_WORKSPACE_PREPARATIONS"; then
    echos "DOTFILES_WORKSPACE_PREPARATIONS: All done";
  else
    echou "Prepare a workspace at 'DOTFILES_WORKSPACE_PREPARATIONS'";
    all_ok="false";
  fi

  if ! grep -RF "TOKEN_""DOTFILES_BRANCH_PREPARATIONS"; then
    echos "DOTFILES_BRANCH_PREPARATIONS: All done";
  else
    echou "Prepare a new branch at 'DOTFILES_BRANCH_PREPARATIONS'";
    all_ok="false";
  fi

  if [[ "$all_ok" == "true" ]]; then
    _ret_13048749814="true";
  fi
}

command_workspace()
{
  set_args "--name=$default_workspace_name --list --help" "$@";
  eval "$get_args";

  if [[ "$list" == "true" ]]; then
    workspace_list;
    return 0;
  fi

  # Call helper function from workspace.sh. Must make sure that such a worksapce
  # name actually exists.
  declare -r funcname="prepare_${name}_workspace";
  if ! declare -F "$funcname" > /dev/null; then
    echon "You can add workplaces by adding the function $funcname to workspace.sh";
    abort "Workspace $text_bold${name}$text_normal does not exist";
  fi
  "prepare_${name}_workspace"; # Function in workspace.sh must be named accordingly
  echok "Prepared workspace $text_user_soft${name}$text_normal";
}

command_show_manual()
{
  echou "Manual: Terminal colours...";
  grep -e "terminal-bold" "$dotfiles/data/colours.txt";
  echou "Manual: (Re-)use old firefox profile (when restored from tarball): visit 'about:profiles'. You might need to sudo snap refresh firefox to get newest version.";
}

command_install_idea()
{
  set_args "--help" "$@";
  eval "$get_args";

  declare -r filename="ideaIC-2023.3.3.tar.gz";
  declare -r direct_link="https://download.jetbrains.com/idea/${filename}";
  pushd "$HOME/Downloads";
  wget -c "$direct_link";
  sha256sum -c <<< "dc123ded3c7ede89e7cd3d4d5e46fada96b8763f648cd0cdbc5b7d6e26203fd2 ideaIC-2023.3.3.tar.gz";
  declare -r dir_name="idea-IDE"; # Used in $dotfiles/dot/bashrc_personal
  ensure_directory "$dir_name";
  tar -xzf "${filename}" -C "$dir_name" --strip-components=1;
  popd;
}

command_install_nala_legacy()
{
  errchof "I think nala legacy build was broken last time I tried";
  if ! test_user "Continue?"; then abort "Aborted by user"; fi

  declare -r base_dir=~"/github";
  dealare -r nala_dir="$base_dir/nala";
  if [[ -d ~/github/nala ]]; then abort "Directory $nala_dir already exists"; fi

  # Install nala from source as legacy support for Ubuntu 20
  errchol "Installing nala dependencies...";
  sudo apt-get install -y wget build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev libbz2-dev

  errchol "Downloading nala dource code...";
  ensure_directory "$base_dir";
  pushd "$base_dir";
  git clone https://gitlab.com/volian/nala.git;
  pushd nala/;

  errchol "Building legacy version";
  sudo make legacy;
  #sudo make legacy-update to update

  errchok "Installed: nala legacy";
  popd
  popd
}

command_install_missing_term_readkey()
{
  declare confirm="false";
  set_args "--yes" "$@";
  eval "$get_args";
  [[ "$yes" == "true" ]] && confirm="true";

  # Fix git warning missing term::readkey for interactive add
  errchol "$FUNCNAME: Trying to fix missing Term::ReadKey";
  apt-cache search term.*readkey;
  if [[ "$confirm" == "true" ]] || test_user "Install libterm-readkey-perl?"; then
    sudo apt install libterm-readkey-perl;
  else
    errchol "$FUNCNAME: declined";
  fi
}


command_install_collected_apt()
{
  # This function install different utilities that can be easily loaded by apt
  echol "Installing collected apt packages...";
  {

    [[ "$(lsb_release -rs)" == 23.* ]] ||
    {
      {
        # Allow vim 9 on ubuntu
        sudo add-apt-repository ppa:jonathonf/vim &&
        sudo apt install vim;
      } ||
      {
        errchow "Installing vim-9 failed. Falling back to vim-gtk3";
        sudo apt install vim-gtk3;
      };
    } &&
    sudo apt install \
      git \
      bat \
      ripgrep \
      universal-ctags \
      xclip \
      net-tools \
      curl \
      iftop \
      shellcheck \
      git-delta \
    &&
    {
      # Need new firefor, else our profile backup could be too new
      declare prg;
      for prg in snap firefox; do
        sudo snap info "$prg" &&
          sudo snap install "$prg" &&
          sudo snap refresh "$prg";
      done
    }
    echok "Installed collected apt packages";
  } ||
  errchoe "$FUNCNAME: Failed to install collected (some) apt packages";
}

command_install_diff_highlight()
{
  errchol "$FUNCNAME";
  # Didnt work
#  errchoi "Downloading git diff-highlight from: $git_diff_hl_url";
#  wget "$git_diff_hl_url";

  # Use local file
  errchot "Using hardcoded path to existing diff-highlight script";
  errchot "Using ~ as target path (instead of the path chosen in ./install)";
  declare -r spath="/usr/share/doc/git/contrib/diff-highlight/diff-highlight";
  declare -r tpath=~/".local/bin/diff-highlight";

  if [[ -f "$tpath" ]]; then
    errchos "installing diff-highight [file foud: $tpath]";
    return 0;
  fi

  declare mode;
  mode="$(sudo stat --format '%a' -- "$spath")"
  if (( "${mode:2:1}" % 2 != 1 )); then
    echol "Making diff-highight executable...";
    sudo chmod +x "$spath";
  else
    echot "If you expected to make diff-highlight executable.. it did not happen";
    progress_sleep 10 "Going to continue with installation anyway.";
  fi

  if [[ ! -f "$spath" ]]; then
    abort "No regular file: $spath";
  fi
  ensure_directory ~/.local/bin;
  cp -v "$spath" ~/.local/bin;

  # TODO Is it enough to make sourece executable?
  chmod u+x "$tpath";
  # shellcheck disable=SC2010
  ls -Fh -A -lD ~/.local/bin | grep --color=auto -e "diff-highlight";
  errchok "Installed diff-highlight script";
}

command_install_cpan()
{
  # CPAN is from perl and does the git interactive immediate key presses
  sudo cpan Term::ReadKey;
}

command_install_difftastic()
{
  declare -r difft_path="/usr/local/bin/difft";
  if [[ -x "$difft_path" ]]; then
    errchos "[binary exists] installing difftastic";
    return 0;
  fi
  ensure_directory /tmp/difftastic;
  cd /tmp/difftastic;
  wget -c https://github.com/Wilfred/difftastic/releases/download/0.52.0/difft-x86_64-unknown-linux-gnu.tar.gz;
#  wget -c https://github.com/Wilfred/difftastic/releases/download/0.52.0/difft-aarch64-unknown-linux-gnu.tar.gz;
  tar -xvzf difft-x86_64-unknown-linux-gnu.tar.gz;
  sudo mv -v difft "$difft_path";
  # shellcheck disable=SC2010
  ls -alF /usr/local/bin | grep -ie difft;
  errchol "$text_green✓ Installed: difftastic $text_dim$difft_path$text_normal";
}

command_generate_ssh_keypairs()
{
  # TOKEN_DOTFILES_USER_CREDENTIALS
  #generate_single_ssh_keypair --silent -f=id_example -C="Example.Name@emal.com";
  #generate_single_ssh_keypair --silent -f=id_alias -C="AnotherAlias";
  abort "Unavailable (add credentials or remove this line)";
  errchol "Done: Creating ssh key pairs";
}

# ┌────────────────────────┐
# │ Helpers                │
# └────────────────────────┘

# Outputs 1 when file is being created
create_if_missing()
{
  if [ "$#" -ne 1 ]; then
    abort "ensure_file() with wrong number of arguments";
  fi

  if [[ -a "$1" ]]; then
    printf "0";
  else
    touch "$1";
    errchok "Created file [$1]";
    printf "1";
  fi
}

generate_single_ssh_keypair()
{
  # Using the same parameter names as ssh-keygen
  set_args "-f= -t=ed25519 -C --silent" "$@";
  declare type="$_t";
  declare file="$_f";
  eval "$get_args";

  declare comment="";
  # FIXME I think this _C and $C stuff does not work as intended
  [[ "$C" != "false" ]] && comment="-C $C";

  # TODO Use $silent?

  # Dont overwrite
  if [[ -e ~/.ssh/"$file" ]] || [[ -e ~/.ssh/"$file".pub ]]; then
    if [[ "$silent" == "true" ]]; then
      errchos "[ssh-keypair exists already] generating ssh keypair {$@}";
      return 0;
    else
      abort "File already exists: $file or $file.pub";
    fi
  fi

  pushd ~/.ssh/;
  errchoi "Creating ssh key pair [$@]";
  # shellcheck disable=SC2086
  ssh-keygen -N "" -t "$type" -f "$file" $comment;  # Split words in $comment
  # shellcheck disable=SC2010
  ls -alF | grep --color=auto -F "$file";
  popd;
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
  --force: Skip credentials check. Dotfile smight not work correctly.";
declare -r install_help_string="Install components (incomplete)
DESCRIPTION
  Install individual components by specifying them as --argument(s). Targets are
  executed in unspecified order.
OPTIONS
  --fzf: Install fzf command line fuzzy finder
  --mcfly: Install mcfly shell history search
  --nvim: Install nvim text editor";
declare -r symlink_dotfiles_help_string="Crete symlinks to files in dot/
OPTIONS
  --user=USER: Link to /home/USER instead of /home/$(whoami)";
declare -r add_credentials_help_string="List places where to add credentials
DESCRIPTION
  Greps for TOKEN_""DOTFILES_USER_CREDENTIALS token, which identifies the lines
  where to add user credentials.";
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
  corresponding function name.";
declare -r install_idea_help_string="Install IntelliJ IDEA free version
DESCRIPTION
  Download IDEA and unpack tarball to ~/Downloads/idea-IDE. This path matches
  the addition we make to PATH in our bashrc_personal.";

# Transition to provided command
subcommand "${@}";
