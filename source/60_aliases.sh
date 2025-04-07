## For a full list of active aliases, run `alias`.

# Unix
alias zshrl='source ~/.zshrc; exec zsh -l; echo ".zshrc reloaded"'
alias zgrl="zgenom reset && zgenom clean && exec zsh -l && echo 'zgenom reloaded'"

# Shortcuts
alias android="cd ~/Uber/android"

# Build Systems
# alias bazel="./bazelw"
alias buck="./buckw"
alias lint='./lintw'

# Fzf
alias fzf="fzf --style full --preview 'fzf-preview.sh {}' --bind 'focus:transform-header:file --brief {}'"

# Include custom aliases
if [[ -f ~/.aliases.local ]]; then
	source ~/.aliases.local
fi