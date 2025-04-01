if [[ ! -z "$DEVPOD_NAME" ]]; then
    # Install latest version on devpod
    if [[ ! -f "$HOME/.fzf.zsh" ]]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        echo "y y n " | tr ' ' '\n' | ~/.fzf/install
    fi
    export FZF_PATH="$HOME/.fzf"
    export PATH="$HOME/.fzf/bin:$PATH"
    source "$HOME/.fzf.zsh"
fi

## Fzf (The following setup is from https://github.com/junegunn/fzf)
export FZF_DEFAULT_OPTS="--height=100% --style full"
# Setting fd as the default source for fzf; add `--hidden`` so that hidden files are included below
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --follow --exclude .git'
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'--bind="ctrl-o:execute(code {})+abort"'

# To apply the command to CTRL-T as well
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

# CTRL-Y to copy the command into clipboard using pbcopy
export FZF_CTRL_R_OPTS="
  --multi
  --height=60%
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy the command into the clipboard'"

# fzf-tab
zstyle ":completion:*:git-checkout:*" sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'