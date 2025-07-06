## For a full list of active aliases, run `alias`.
alias cat='bat --style plain --paging=never'

# Include custom aliases
if [[ -f ~/.aliases.local ]]; then
	source ~/.aliases.local
fi