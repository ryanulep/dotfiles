#!/usr/bin/env bash

export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load.
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="headline"

zstyle ':omz:update' mode auto      # update automatically without asking

source $ZSH/oh-my-zsh.sh

export DOTFILES="$HOME/dotfiles"

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