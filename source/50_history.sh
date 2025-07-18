setopt hist_ignore_all_dups inc_append_history
setopt share_history
HISTFILE=~/.zsh_history
HISTORY_IGNORE='(l|ls|ll|cd|cd ..|z|pwd|exit|date|history|clear|tmux|tmux attach)'
HISTSIZE=290000
SAVEHIST=$HISTSIZE

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

export ERL_AFLAGS="-kernel shell_history enabled"

# can also bind to atuin-up-search
# bindkey '^s' atuin-search