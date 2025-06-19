#!/usr/bin/env bash

export DOTFILES="$HOME/.dotfiles"

# Enable Oh My Zsh auto-update
zstyle ':omz:update' mode auto

# TODO: Figure out why the below doesn't work with custom setup
# Set name of the theme to load.
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="headline"

[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local || true

source $DOTFILES/copy/.oh-my-zsh/custom/themes/headline.zsh-theme

# Source all files in "source"
function src() {
  local file
  if [[ "$1" ]]; then
    source "$DOTFILES/source/$1.sh"
  else
    for file in $DOTFILES/source/*; do
      source "$file"
    done
  fi
}

# Run dotfiles script, then source.
function dotfiles() {
  $DOTFILES/bin/dotfiles "$@" && src
}

src

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local || true