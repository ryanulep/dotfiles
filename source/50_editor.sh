# Set default editors to Vim
export EDITOR=vim
export VISUAL="$EDITOR"

# enable colored output from ls, etc. on FreeBSD-based systems
export CLICOLOR=1

# Makes color constants available
autoload -U colors
colors

## Bat (https://github.com/sharkdp/bat)
export BAT_CONFIG_PATH="$HOME/.config/bat/bat.conf"

# To opt in to Homebrew analytics, `unset` this in ~/.zshrc.local .
export HOMEBREW_NO_ANALYTICS=1