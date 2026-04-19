setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_reduce_blanks
setopt hist_verify
setopt hist_ignore_space
setopt inc_append_history
setopt share_history
setopt hist_find_no_dups
setopt hist_no_store
setopt hist_fcntl_lock
setopt extended_history

HISTFILE=~/.zsh_history
HISTSIZE=290000
SAVEHIST=$HISTSIZE

HISTORY_IGNORE='(l|ls|ll|la)( * )|cd|cd( * )|pwd|exit|date|history( * )|clear|reset|tmux( * )|(lg|lazygit|tig)|git (status|diff|log)( * )|jj (st|status|diff|log|show|obslog|evolog)( * )|jj bookmark list( * )|jj git remote list( * )'

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

export ERL_AFLAGS="-kernel shell_history enabled"

# can also bind to atuin-up-search
# bindkey '^s' atuin-search