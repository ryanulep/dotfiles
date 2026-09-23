# ensure dotfiles bin directory is loaded first
PATH="$DOTFILES/bin:$HOME/bin:/usr/local/sbin:$PATH"
# Devpods can have a modern standalone fzf alongside an older apt binary.
# Select it before any plugin evaluates fzf options; detection must not depend
# on DEVPOD_NAME (which is absent from noninteractive SSH/setup environments).
if [[ -x "$HOME/.fzf/bin/fzf" ]]; then
  PATH="$DOTFILES/bin:$HOME/bin:$HOME/.fzf/bin:$PATH"
fi
PATH="$PATH:/opt/homebrew/bin"
PATH="$PATH:/opt/homebrew/sbin"

export -U PATH
