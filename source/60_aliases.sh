## For a full list of active aliases, run `alias`.
alias cat='bat --style plain --paging=never'

# Fzf
alias fzf="fzf --style full --preview 'bat -n --theme auto:system --color=always {}' --bind 'focus:transform-header:file --brief {}'"

# Include custom aliases
if [[ -f ~/.aliases.local ]]; then
	source ~/.aliases.local
fi