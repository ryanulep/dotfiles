# ensure dotfiles bin directory is loaded first
PATH="$DOTFILES/bin:$HOME/bin:/usr/local/sbin:$PATH"
PATH="$PATH:/opt/homebrew/bin"
PATH="$PATH:/opt/homebrew/sbin"

export -U PATH