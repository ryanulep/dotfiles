#!/usr/bin/env bash

export DOTFILES="$HOME/.dotfiles"
export ZSH_CUSTOM=$DOTFILES/config/ohmyzsh/custom

# Enable Oh My Zsh auto-update
zstyle ':omz:update' mode auto

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="intheloop"
# ZSH_THEME="headline-modern"

source "$ZSH_CUSTOM/themes/headline-modern.zsh-theme"

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