# Use fd when available — respects .gitignore, faster than find
if (( $+commands[fd] )); then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
fi

export FZF_DEFAULT_OPTS='
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
export FZF_CTRL_T_OPTS="
  --height ~80%
  --style full
  --preview 'fzf-preview.sh {}'
  --walker-skip .git,node_modules,target
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"
# CTRL-Y to copy the command into clipboard using pbcopy
export FZF_CTRL_R_OPTS='
  --tmux 90%
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
function _fzf_tab_resize() {
    local width
    local -a flags=('--preview-window=right:50%')
    if [[ -n "$TMUX" ]]; then
        width=$(tmux display-message -p '#{window_width}')
        zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
    else
        width=$COLUMNS
        zstyle ':fzf-tab:*' fzf-command fzf
        flags+=('--height=33%')
    fi
    zstyle ':fzf-tab:*' fzf-flags $flags
    local popup_width=$(( width * 3 / 4 ))
    (( popup_width < 80 )) && popup_width=80
    zstyle ':fzf-tab:*' popup-min-size $popup_width 15
}
_fzf_tab_resize
add-zsh-hook precmd _fzf_tab_resize
zstyle ":completion:*:git-checkout:*" sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':fzf-tab:*' continuous-trigger 'tab'
zstyle ':fzf-tab:complete:man:*' fzf-preview 'man $word | col -bx | bat --language=man --color=always --paging=never'
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
	fzf-preview 'echo ${(P)word}'
zstyle ':fzf-tab:complete:*:*' fzf-preview 'fzf-tab-preview $realpath'

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