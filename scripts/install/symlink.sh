#!/usr/bin/false

# This file is only sourced by the install/run.sh.
# Here we only define functions. We do not source other files.

symlink_bash_aliases() {
  echo "bash_aliases..."
  # Our dotfile uses .sh file extension to convince universal-ctags to generate
  # tags, but the link is named ".bash_aliases" because its stock Ubuntu default
  # and we do some 'sed'in and grepping for it in 'symlink_bashrc()'.
  declare -r path="$HOME/.bash_aliases"
  if [ -f "$path" ]; then
    echo "skip"
  else
    echo "installing..."
    command ln -v -s "$dotfiles/dot/bash_aliases.sh" "$path" &&
      echo "done"
  fi
}

symlink_bash_completion() {
  # Install alias completion
  subcommand rundir "$dotfiles" deploy --name=".bash_completion" --yes --keep --file="$completion_path" --dir="$HOME" || :
  echo
}

symlink_bash_gitcompletion() {
  # Git completion.
  # Maybe also /etc/bash_completion.d/git
  declare git_completion="/usr/share/bash-completion/completions/git"
  if [[ ! -f "$git_completion" ]]; then
    git_completion="$dotfiles/extern/git-completion.bash"
    echon "Using our own git-completion.bash"
  fi
  subcommand rundir "$dotfiles" deploy --yes --keep \
    --file="$git_completion" --name="git-completion.bash" --dir="$HOME/.local/share"
  echo
}

symlink_bashrc() {
  # use .bashrc_personal
  # FIXME This is scuffed
  declare -r brcp="$HOME/.bashrc"
  declare -r brcl="source ~/dotfiles/dot/bashrc_personal; # The install command greps for this line. Do not change it."
  echo "bashrc_personal..."
  if [ ! -f "$brcp" ]; then
    echo "creating file..."
    touch "$brcp"
  else
    echo "(file exists)"
  fi

  # Prevent setting of HISTSIZE and HISTFILESIZE. Hope to prevent truncation of
  # the file before it is overwritten by our dot/bashrc_personal.
  sed -i -e '/HISTSIZE/ s/^[^#]/:; # [history handled by dotfiles] &/' "$brcp"
  sed -i -e '/HISTFILESIZE/ s/^[^#]/:; # [history handled by dotfiles] &/' "$brcp"

  # Prevent sourcing of .bash_aliases. Hope to prevent sourcing the aliases
  # symlink before our dopt/bashrc_personal has sourced dot/git-completion.bash.
  sed -i -e '/\(\.\|source\) .*\.bash_aliases\( \|$\)/ s/^[^#]/:;\n# [aliases handled by dotfiles] &/' "$brcp"

  if grep -q -F "$brcl" "$brcp"; then
    echo "skip"
  else
    echo "installing..."
    # Source dot/bashrc_personal but keep the default bashrc in case it is
    # interesting.
    echo "$brcl" >>"$brcp" &&
      echo "done"
  fi
}

symlink_btopconf() {
  subcommand run "$dotfiles" deploy --yes --keep \
    --file="$dotfiles/dot/btop.conf" --dir="${HOME}/.config/btop"
}

symlink_ectags() {
  errchoe "Deprecated because exuberant ctags is outdated. Use symlink_uctags instead."
  subcommand run "$dotfiles" deploy --yes --keep \
    --file="$dotfiles/dot/ctags" --name=".ctags" --dir="$HOME"
}

symlink_uctags() {
  # subcommand run "$dotfiles" deploy --yes --keep \
  #   --file="$dotfiles/dot/ignore.ctags" --dir="$HOME/.config/ctags"
  # subcommand run "$dotfiles" deploy --yes --keep \
  #   --file="$dotfiles/dot/langmap.ctags" --dir="$HOME/.config/ctags"

  # linnking to ~/.config/ctags/ used to work but current it does not. Per
  # readme on GitHub only ~/.ctags.d/ is considered.

  subcommand run "$dotfiles" deploy --yes --keep \
    --file="$dotfiles/dot/ignore.ctags" --dir="$HOME/.ctags.d"
  subcommand run "$dotfiles" deploy --yes --keep \
    --file="$dotfiles/dot/langmap.ctags" --dir="$HOME/.ctags.d"
}

symlink_gdbinit() {
  subcommand run "$dotfiles" deploy --yes --keep \
    --file="$dotfiles/dot/gdbinit" --name=".gdbinit" --dir="$HOME/"
}

symlink_gitconfig() {
  subcommand run "$dotfiles" deploy --yes --keep \
    --file="$dotfiles/dot/gitconfig" --name=".gitconfig" --dir="$HOME"
}

symlink_gitignore_global() {
  subcommand run "$dotfiles" deploy --yes --keep \
    --file="$dotfiles/dot/gitignore_global" --name=".gitignore_global" --dir="$HOME"
}

symlink_iftoprc() {
  subcommand run "$dotfiles" deploy --yes --keep \
    --file="$dotfiles/dot/iftoprc" --name=".iftoprc" --dir="$HOME"
}

symlink_inputrc() {
  subcommand run "$dotfiles" deploy --yes --keep \
    --file="$dotfiles/dot/inputrc" --name=".inputrc" --dir="$HOME"
}

symlink_neovim() {
  subcommand run "$dotfiles" deploy --yes --keep \
    --file="$dotfiles/dot/nvim" --dir="$HOME/.config"
}

symlink_ripgrep_config() {
  subcommand run "$dotfiles" deploy --yes --keep \
    --file="$dotfiles/dot/ripgrep.conf" --dir="$HOME/.config"
}

symlink_shellcheck_config() {
  subcommand run "$dotfiles" deploy --yes --keep \
    --file="$dotfiles/dot/shellcheckrc" --name=".shellcheckrc" --dir="$HOME"
}

symlink_ssh_config() {
  subcommand rundir "$dotfiles" deploy --keep --yes \
    --file="$dotfiles/dot/ssh_config" --name="config" --dir="${HOME}/.ssh/"
  chmod 600 "${HOME}/.ssh/config"
}

symlink_toprc() {
  subcommand run "$dotfiles" deploy --yes --keep \
    --file="$dotfiles/dot/toprc" --dir="$HOME/.config/procps/"
}

symlink_vim_ftplugin() {
  may_fail -- subcommand run "$dotfiles" deploy --yes --keep \
    --file="$dotfiles/dot/ftplugin" --dir="$HOME/.vim"
}

symlink_vim_operatorhighlight() {
  # install operator coloration
  echo "C++ operator colors (vim)..."
  path="$HOME/.vim/after/syntax"
  file="cpp.vim"
  if [ -f "$path/$file" ]; then
    echo "skip"
  else
    if [ ! -d "$path" ]; then
      echo "creating directory..."
      mkdir -p -v "$path"
    else
      echo "(directory exists)"
    fi
    echo "installing..."
    ln -s "$dotfiles/.vim/after/syntax/cpp.vim" "$path/$file" &&
      echo "done"
  fi
}

symlink_vimrc() {
  subcommand run "$dotfiles" deploy --yes --keep \
    --file="$dotfiles/dot/vimrc" --name=".vimrc" --dir="$HOME"
}

# install wombat colorscheme for vim
#  if false; then
#      echo "wombat (vim colorscheme)"
#if [ -d "$dotfiles/.vim/
#      echo "Installing wombat colorscheme for vim"
#      git clone "https://github.com/vim-scripts/wombat256.vim.git" &&
#      echo "Removing .git from wombat"
#      rm -rf "${dotfiles:?}/"
# TODO lol watch out this is dotfiles dir
#  fi
