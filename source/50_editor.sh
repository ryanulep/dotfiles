# Set default editors to Vim
export EDITOR="$(which nvim >/dev/null && echo 'nvim' || echo 'vim')"
export VISUAL="$EDITOR"

# enable colored output from ls, etc. on FreeBSD-based systems
export CLICOLOR=1

# Makes color constants available
autoload -U colors
colors