setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_reduce_blanks
setopt hist_verify
setopt hist_ignore_space
# SHARE_HISTORY already appends commands; these modes are mutually exclusive.
unsetopt inc_append_history inc_append_history_time
setopt share_history
setopt hist_find_no_dups
setopt hist_no_store
setopt hist_fcntl_lock
setopt extended_history

HISTFILE=~/.zsh_history
HISTSIZE=400000
SAVEHIST=290000

# One grouped Zsh pattern; (| *) matches either no arguments or arguments.
HISTORY_IGNORE='((l|ls|ll|la|cd|pwd|exit|date|history|clear|reset|tmux|lg|lazygit|tig|nvim|vim|ranger|bat|cat)(| *)|git (status|diff|log)(| *)|jj (st|status|diff|log|show|obslog|evolog)(| *)|jj bookmark list(| *)|jj git remote list(| *))'

# Completion fallback exposed Zsh internal functions (b7a61b1); keep history-only.
ZSH_AUTOSUGGEST_STRATEGY=(history)
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=200

# history-substring-search: up/down arrows search history by typed prefix
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

export ERL_AFLAGS="-kernel shell_history enabled"

# can also bind to atuin-up-search
# bindkey '^s' atuin-search
