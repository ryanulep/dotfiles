# macOS specific configuration
is_osx || return 1

[[ ! "$(type -P brew)" ]] && e_error "Brew recipes need Homebrew to install." && return 1

brew upgrade
brew install mas
brew bundle install --file=$DOTFILES/conf/packages/Brewfile
brew cleanup