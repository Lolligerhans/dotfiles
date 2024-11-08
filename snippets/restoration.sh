#!/usr/bin/env bash

# Backup restoration script. It should be part of a backup tarball, to
# automatically extract the contents to relevant locations.

# ┌────────────────────────┐
# │ Info ❔                │
# └────────────────────────┘

# ❗ Some of these operations are broken if the new username differs from the
#    old: Permissions, symlinks, etc can break. In these cases, maybe just copy
#    stuff by hand as needed.

# This script is used when initializing dotfiles on a machine to extract the
# backup tarball.
#
# The backup tarball is created by the default runscript command
# "restoration_tarball".
#
# The backup tarball contains ssh_keys, firefox profiles and dotfiles. This
# speeds up the setup after installing the OS.

# ┌────────────────────────┐
# │ Config ⚙               │
# └────────────────────────┘

set -o errexit -o nounset -o errtrace -o functrace -o pipefail;

# ┌────────────────────────┐
# │ Constants              │
# └────────────────────────┘

# Example:
#   Get backup $backup_name == backup-time_xyz.tar.bz2
#   Unpack to $destination/$backup_basename == /tmp/restoration/backup-time_xyz
#   Obtain $destination/$backup_basename/home == /tmp/restoration/backup-time_xyz/home
#   Copy the 'home' directory to '/' (overwriting only exactly the things that
#   were present in the backup).

declare -g caller_path;
caller_path="$(pwd -P)";
declare -r caller_path;
cd "$(dirname "${BASH_SOURCE}")";
declare -g parent_path;
parent_path="$(pwd -P)";
declare -r parent_path;

declare -r backup_default_name="NO_BACKUP_NAME_GIVEN";
# The line containing a token is modified with the 'sed' program to contain the
# right backup name. Do not modify; do not remove the token.
declare -r backup_name="$backup_default_name"; # TOKEN_backup_name
# Some sanity checks
{
  if [ "${backup_name}" == "$backup_default_name" ]; then
    1>&2 echo "[ERROR] No backup name given. Aborting.";
    exit 1;
  fi
  if [ ! -f "./$backup_name" ]; then
    1>&2 echo "[ERROR] Backup $backup_name not found. Aborting.";
  fi
  if ! grep -e '\.tar\.bz2$' <<< "$backup_name"; then
    1>&2 echo "[WARNING] Expected .tar.bz2 extension.";
  fi
}
declare backup_basename;
backup_basename="$(basename -s .tar.bz2 "${backup_name}")";
declare -r backup_basename;
declare -r destination="/tmp/restoration";

echo "[LOG] Restoring backup: $backup_name";
echo "[LOG] Unpacking with basename: $backup_basename";
echo "[LOG] Unpacking in (temporary) destination: $destination";

# ┌────────────────────────┐
# │ Helpers                │
# └────────────────────────┘

sanity_check()
{
  if [ -d "$destination" ]; then
    1>&2 echo "[ERROR] Destination '$destination' already exists. Aborting.";
    echo "[NOTE] This is making sure that the script works as intended.";
    echo "[NOTE] Remove directory '$destination' to continue.";
    exit 1;
  fi
}

extract_tarball_to_tmp_dir()
{
  declare -r backup_path="./$backup_name";

  mkdir -vp "${destination}/${backup_basename}";
  tar --force-local -C "$destination/$backup_basename/" -xjpf "${backup_path}";
  echo "[OK] Extracted to temporary location ${destination}/$backup_basename";

  # Verification
  declare -r expected_home_dir="${destination}/$backup_basename/home";
  if [ ! -d "$expected_home_dir" ]; then
    1>&2 echo "[WARNING] Missing expected directory: $expected_home_dir";
  fi
}

show_contents()
{
  set -v;
  tree --version || sudo apt install tree ||
    echo "[!] Tree unavailable";
  pwd;
  echo "Restoration content:";
  tree -aDL 2 "$PWD" || ls -lFhA --color=auto ./* ||
    echo "[!] Cannot list directory $PWD";
  set +v;
}

get_permission()
{
  declare confirmation;
  read -rp "Copy restored $then_user's backed up files to new $now_user? (y/n)" confirmation;
  if [ "$confirmation" == "y" ]; then
    printf "%s" "y";
  else
    printf "%s" "n";
  fi
}

# ┌────────────────────────┐
# │ Commands               │
# └────────────────────────┘

sanity_check;
extract_tarball_to_tmp_dir;
cd "${destination}/$backup_basename/home/";
show_contents;
declare then_user now_user;
now_user="$(whoami)";
then_user="$(command ls | tail -1)";
declare -r now_user then_user;

declare choice;
choice="$(get_permission)";
if [[ "$choice" == "n" ]]; then
  echo "[!] Restoratino aborted. See '${destination}' for restoratino files.";
  1>&2 echo "Aborted";
  exit 1;
fi

# -r: Recursive
# -p: Preserve permissions
set -v;
# TODO Add -f flag to overwrite files?
sudo cp -rp "./$then_user" "/home";
set +v;
echo "[OK] Backup fully restored";
