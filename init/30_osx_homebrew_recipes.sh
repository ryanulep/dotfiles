# macOS specific configuration
is_osx || return 1

[[ ! "$(type -P brew)" ]] && e_error "Brew recipes need Homebrew to install." && return 1

# Installing missing tools should not upgrade every existing application.
if [[ "$DOTFILES_ACTION" == upgrade ]]; then
  brew bundle install --file="$DOTFILES/conf/packages/Brewfile"
else
  brew bundle install --no-upgrade --file="$DOTFILES/conf/packages/Brewfile"
fi
