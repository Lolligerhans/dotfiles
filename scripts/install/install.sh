#/bin/false

# version 0.0.0

# Install functions. Installation of parts are moved here to keep ./run.sh
# short. We keep 1 installation per function to allow calling them individually
# from run.sh.

install_mcfly()
{
  declare -r link="https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh";
  echol "Installing mcfly";
  if curl -LSfs "$link" | sudo sh -s -- --git cantino/mcfly; then
    echok "Installed mcfly";
    return 0;
  else
    errchoe "Failed to install mcfly";
    return 1;
  fi
}

install_nvim()
{
  declare -r link='https://github.com/neovim/neovim-releases/releases/download/v0.10.0/nvim-linux64.deb';
  echol "Installing nvim v0.10.0";
  pushd ~/Downloads || return;
  wget -q --show-progress -c "$link";
  declare check="false";
  checksum_verify_sha256 check '46522ddd0ed56b22a889a25c247a9344d5767ec73d76f48dc54867c893214ffc  nvim-linux64.deb';
  if [[ "$check" != "true" ]]; then
    errchoe "Failed to verify checksum";
    return 1;
  fi
  sudo apt install ./nvim-linux64.deb || return;
  echok "Installed nvim";
  popd;
}

install_fzf()
{
  declare -i ret="";
  if ! (
    echol "Installing fzf";
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf || :;
    # no autocompletion, no key bindings, yes update shell config
    declare -r input=$'n\nn\ny\n';
    ~/.fzf/install <<< "$input" || return; # When this script changes we must adjust input
    echok "Installed fzf";
  ); then
    ret="$?";
    errchoe "Failed to install fzf";
    errchon "Try installing an older fzf from apt instead: sudo apt install fzf";
    return "$ret"; # Propagate error
  fi
}
