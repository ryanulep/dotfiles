## For a full list of active aliases, run `alias`.
command -v bat >/dev/null 2>&1 && alias cat='bat --style plain --paging=never'

# Alias lg -> lazygit only if it's installed
if (( $+commands[lazygit] )); then
  alias lg='lazygit'
fi

# Include local aliases, if they exist
if [[ -f ~/.aliases.local ]]; then
	source ~/.aliases.local
fi