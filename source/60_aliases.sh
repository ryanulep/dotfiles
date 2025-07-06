## For a full list of active aliases, run `alias`.
command -v bat >/dev/null 2>&1 && alias cat='bat --style plain --paging=never'

# Include custom aliases
if [[ -f ~/.aliases.local ]]; then
	source ~/.aliases.local
fi