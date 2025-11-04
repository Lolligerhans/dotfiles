#!/bin/false

# version 0.0.0

# Install functions. Installation of parts are moved here to keep ./run.sh
# short. We keep 1 installation per function to allow calling them individually
# from run.sh.

install_atkynsonmono_nerd_font() {
  # Install nerd font version of "Atkinson Hyperledgible"
  declare -r link="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/AtkinsonHyperlegibleMono.zip"
  declare -r checksumFile="checksums/atkinson.txt"
  declare -r file="AtkinsonHyperlegibleMono.zip"

  echol "Installing Atkinson Nerd Font"
  pushd "${HOME}/Downloads/" || return
  wget_verify_sha256_file "${link}" "${parent_path}/${checksumFile}"
  popd || return
  subcommand load_font --zip="${HOME}/Downloads/${file}"
  echok "Installed Atkinson Nerd Font"
}

install_cppreference() {
  declare -r download_link="https://github.com/PeterFeicht/cppreference-doc/releases/download/v20241110/html-book-20241110.tar.xz"
  declare -r checksum_file="checksums/cppreference.txt"
  declare -r checksum_file_fullpath="${parent_path}/${checksum_file}"
  declare -r download_directory="${HOME}/Downloads/cppreference"
  declare -r downloaded_file="html-book-20241110.tar.xz"
  show_variable download_link
  show_variable checksum_file_fullpath
  show_variable downloaded_file
  ensure_directory "$download_directory"
  pushd "$download_directory"
  # Use full path from in ~/Downloads
  wget_verify_sha256_file "$download_link" "$checksum_file_fullpath"
  command tar -xJf "$downloaded_file"
  popd
  echok "Installed cppreference"
}

install_diff_highlight() {
  errchol "${FUNCNAME[0]}"
  # Didnt work
  #  errchoi "Downloading git diff-highlight from: $git_diff_hl_url"
  #  wget "$git_diff_hl_url"

  # Use local file
  errchot "Using hardcoded path to existing diff-highlight script"
  errchot "Using ~ as target path (instead of the path chosen in ./install)"
  declare -r spath="/usr/share/doc/git/contrib/diff-highlight/diff-highlight"
  declare -r tpath=~/".local/bin/diff-highlight"

  if [[ -f "$tpath" ]]; then
    errchos "installing diff-highight [file foud: $tpath]"
    return 0
  fi

  declare mode
  mode="$(sudo stat --format '%a' -- "$spath")"
  if (("${mode:2:1}" % 2 != 1)); then
    echol "Making diff-highight executable..."
    sudo chmod +x "$spath"
  else
    echot "If you expected to make diff-highlight executable.. it did not happen"
    progress_sleep 10 "Going to continue with installation anyway."
  fi

  if [[ ! -f "$spath" ]]; then
    abort "No regular file: $spath"
  fi
  ensure_directory ~/.local/bin
  cp -v "$spath" ~/.local/bin

  # TODO Is it enough to make sourece executable?
  chmod u+x "$tpath"
  # shellcheck disable=SC2010
  ls -Fh -A -lD ~/.local/bin | grep --color=auto -e "diff-highlight"
  errchok "Installed diff-highlight script"
}

install_difftastic() {
  declare -r difft_path="/usr/local/bin/difft"
  if [[ -x "$difft_path" ]]; then
    errchos "[binary exists] installing difftastic"
    return
  fi
  ensure_directory /tmp/difftastic
  cd /tmp/difftastic
  wget -c https://github.com/Wilfred/difftastic/releases/download/0.52.0/difft-x86_64-unknown-linux-gnu.tar.gz
  #  wget -c https://github.com/Wilfred/difftastic/releases/download/0.52.0/difft-aarch64-unknown-linux-gnu.tar.gz
  tar -xvzf difft-x86_64-unknown-linux-gnu.tar.gz
  sudo mv -v difft "$difft_path"
  # shellcheck disable=SC2010
  ls -alF /usr/local/bin | grep -ie difft
}

install_font_fira() {
  declare -r link="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip"
  declare -r checksumFile="checksums/fira.txt"
  declare -r file="FiraCode.zip"

  echol "Installing FiraCode Nerd Font"
  pushd ~/Downloads/ || return
  wget_verify_sha256_file "${link}" "${parent_path}/${checksumFile}"
  popd || return
  subcommand load_font --zip="$HOME/Downloads/${file}"
  echok "Installed FiraCode Nerd Font"
}

install_fzf() {
  if which fzf >/dev/null; then
    echos "fzf (found)"
    return
  fi

  declare -i ret=""
  if ! (
    echol "Installing fzf"
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf || :
    # no autocompletion, no key bindings, yes update shell config
    declare -r input=$'n\nn\ny\n'
    ~/.fzf/install <<<"$input" || return # When this script changes we must adjust input
    echok "Installed fzf"
  ); then
    ret="$?"
    errchoe "Failed to install fzf"
    errchon "Try installing an older fzf from apt instead: sudo apt install fzf"
    return "$ret" # Propagate error
  fi
}

install_gcc() {
  abort "Too cumbersome to build manually stay with 14 from apt"
  manually \
    "Download https://ftp.gwdg.de/pub/misc/gcc/releases/gcc-15.1.0/gcc-15.1.0.tar.xz" \
    "Verify checksum from https://ftp.gwdg.de/pub/misc/gcc/releases/gcc-15.1.0/" \
    "Extract with tar using -J for the .xz compression, creating the gcc-someversion/ folder"
  echok "Installed gcc 15"
}

install_git() {
  echoL "Installing new git from ppa:git-core/ppa"

  {
    # On newer Ubunuts we needed a separate ppa with newer git for specific
    # fixes. Ubuntu 25 already has a newer git already. Remove eventually.
    # LATER: Remove when not used successfully long enough
    if false; then
      sudo add-apt-repository "ppa:git-core/ppa"
    fi
  }

  sudo apt update
  sudo apt install git
  echok "Installed new git"
}

install_jetbrains_mono_nerdfont() {
  declare -r link="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip"
  declare -r file="JetBrainsMono.zip"

  echol "Installing JetBrainsMono Nerd Font"
  wget_verify_sha256 \
    "${link}" \
    "6596922aabaf8876bb657c36a47009ac68c388662db45d4ac05c2536c2f07ade" \
    "${file}"
  subcommand load_font --zip="$HOME/Downloads/${file}"
  echok "Installed JetBrainsMono Nerd Font"
}

install_mcfly() {
  declare -r link="https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh"
  if which mcfly >/dev/null; then
    echos "(found) not installing mcfly"
    return
  fi
  echol "Installing mcfly"
  if curl -LSfs "$link" | sudo sh -s -- --git cantino/mcfly; then
    echok "Installed mcfly"
    return 0
  else
    errchoe "Failed to install mcfly"
    return 1
  fi
}

install_mpk() {
  declare -r link="https://github.com/pluots/mpk/releases/download/v0.2.2/mpk_0.2.2_amd64.deb"
  declare -r file_name="mpk_0.2.2_amd64.deb"
  declare -r sha256="a4917041f0d4099b1407ae0918a945c1ebeb8b108e3ac5ba4555258c4dd05c51"

  pushd ~/Downloads || return
  command wget -q --show-progress -c "$link"

  declare check="false"
  checksum_verify_sha256 check "${sha256}  ${file_name}"
  if [[ "$check" != "true" ]]; then
    command mv -vf "$file_name" "$file_name".bad
    errchoe "Failed to verify checksum"
    return 1
  fi
  sudo apt install "./$file_name" || return

  popd || return
}

install_nvim() {
  set_args "--force --" "$@"
  eval "$get_args"

  echoL "Installing neovim"
  show_variable force

  if [[ "$force" != "true" ]] && command which nvim >/dev/null; then
    echos "(found) not installing nvim"
    return
  fi

  declare -r link="https://github.com/neovim/neovim-releases/releases/download/v0.11.4/nvim-linux-x86_64.deb"
  declare filename
  filename="$(command basename "$link")"
  declare -r filename

  pushd ~/Downloads || return
  command wget -q --show-progress --https-only -c "$link"
  declare check="false"
  checksum_verify_sha256 check "31c064bfce880426a739eae598b9216e83c16598dde07fbc5892fd27e8fdf53a  $filename"

  if [[ "$check" != "true" ]]; then
    command mv -vf "$filename" "${filename}.bad"
    errchoe "Failed to verify checksum"
    return 1
  fi
  command sudo apt install ./"$filename" || return
  popd
}

install_tree_sitter() {
  if which tree-sitter >/dev/null; then
    echos "(found) tree-sitter"
    return 0
  fi
  command cargo install "tree-sitter-cli"
}

install_vundle() {
  if [[ -d "$HOME/.vim/bundle/Vundle.vim" ]]; then
    echos "(found) vundle"
  else
    echo "installing..."
    git clone "https://github.com/VundleVim/Vundle.vim.git" "$HOME/.vim/bundle/Vundle.vim" &&
      echo "Removing .git file from Vundle" &&
      rm -rfv "$HOME/.vim/bundle/Vundle.vim/.git"
  fi
}
