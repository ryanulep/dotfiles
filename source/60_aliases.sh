## For a full list of active aliases, run `alias | fzf`.

# Alias cat only if bat is installed
if (( $+commands[bat] )); then
  alias cat='bat --style plain --paging=never'
fi

# Alias vim only if neovim is installed
if (( $+commands[nvim] )); then
  alias vim='nvim'
fi

# Alias lg -> lazygit only if it's installed
if (( $+commands[lazygit] )); then
  alias lg='lazygit'
fi

# Include local aliases, if they exist
if [[ -f ~/.aliases.local ]]; then
	source ~/.aliases.local
fi