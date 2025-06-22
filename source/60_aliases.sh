## For a full list of active aliases, run `alias`.

# Fzf
alias fzf="fzf --style full --preview 'bat -n --color=always {}' --bind 'focus:transform-header:file --brief {}'"

# Include custom aliases
if [[ -f ~/.aliases.local ]]; then
	source ~/.aliases.local
fi