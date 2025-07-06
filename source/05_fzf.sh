export FZF_DEFAULT_OPTS='
  --tmux 90%
  --style full
  --input-label " Input "
  --bind "result:transform-list-label:
        if [[ -z \$FZF_QUERY ]]; then
          echo \" \$FZF_MATCH_COUNT items \"
        else
          echo \" \$FZF_MATCH_COUNT matches for [\$FZF_QUERY] \"
        fi
        "
  --bind "focus:transform-preview-label:[[ -n {} ]] && printf \" Previewing [%s] \" {}"
  --marker ">"
  --color "border:7,label:15"
  --color "preview-border:6,preview-label:14"
  --color "list-border:2,list-label:10"
  --color "input-border:4,input-label:12"
  --color "prompt:12,info:5"
  --color "spinner:5,pointer:9"
  --color "header-border:3,header:11,header-label:11"
  --color "hl+:2,hl:10"
  --bind "ctrl-o:execute(code {})+abort"'
# To apply the command to CTRL-T as well
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="
  --height ~80%
  --style full
  --preview 'fzf-preview.sh {}'
  --walker-skip .git,node_modules,target
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"
# CTRL-Y to copy the command into clipboard using pbcopy
export FZF_CTRL_R_OPTS='
  --height 60%
  --style full
  --multi
  --header-label ""
  --bind "ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort"
  --color header:italic
  --header "Press CTRL-Y to copy the command into the clipboard"'

# fzf-tab
# To make fzf-tab follow FZF_DEFAULT_OPTS.
# NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
zstyle ":completion:*:git-checkout:*" sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
	fzf-preview 'echo ${(P)word}'

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