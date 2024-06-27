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
    errcho "Failed to install mcfly";
    return 1;
  fi
}
