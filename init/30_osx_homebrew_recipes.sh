# macOS specific configuration
is_osx || return 1

[[ ! "$(type -P brew)" ]] && e_error "Brew recipes need Homebrew to install." && return 1

# Installing missing tools should not upgrade every existing application.
if [[ "$DOTFILES_ACTION" == upgrade ]]; then
  HOMEBREW_NO_INSTALL_CLEANUP=1 brew bundle install --file="$DOTFILES/conf/packages/Brewfile"
else
  HOMEBREW_NO_INSTALL_CLEANUP=1 brew bundle install --no-upgrade --file="$DOTFILES/conf/packages/Brewfile"
fi
# Keep cleanup explicit: removing old keg versions can break pinned environments.
