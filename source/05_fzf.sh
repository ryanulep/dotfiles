# Use fd when available — respects .gitignore, faster than find
if (( $+commands[fd] || $+commands[fdfind] )); then
  # Debian packages fd as fdfind. Avoid following generated Bazel symlink trees.
  _dotfiles_fd=${commands[fd]:-${commands[fdfind]}}
  export FZF_DEFAULT_COMMAND="${(q)_dotfiles_fd} --type f --hidden --exclude .git"
  # Current fzf widgets do not inherit FZF_DEFAULT_COMMAND.
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="${(q)_dotfiles_fd} --type d --hidden --exclude .git"
  unset _dotfiles_fd
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
  --color "hl+:2,hl:10"'
export FZF_CTRL_T_OPTS="
  --height ~80%
  --style full
  --preview 'fzf-tab-preview {}'
  --walker-skip .git,node_modules,target
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"
if (( $+commands[code] )); then
  # Opening an editor only makes sense for file selections, not history/sessions.
  FZF_CTRL_T_OPTS+=" --bind 'ctrl-o:execute(code -- {})+abort'"
fi
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
# Keep fzf-tab's layout independent of global picker options.
# NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
zstyle ':fzf-tab:*' use-fzf-default-opts no
function _fzf_tab_resize() {
    # COLUMNS follows the pane size. Recompute only after a resize; no tmux fork
    # is needed on the prompt path, including when several panes are open.
    local dimensions="${COLUMNS:-80}:${LINES:-24}:${TMUX:+tmux}"
    [[ ${_FZF_TAB_DIMENSIONS:-} == "$dimensions" ]] && return
    _FZF_TAB_DIMENSIONS=$dimensions
    local width=${COLUMNS:-80}
    local -a flags=('--preview-window=right:50%')
    if [[ -n "$TMUX" ]]; then
        zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
    else
        zstyle ':fzf-tab:*' fzf-command fzf
        flags+=('--height=33%')
    fi
    zstyle ':fzf-tab:*' fzf-flags $flags
    local popup_width=$(( width * 3 / 4 ))
    (( popup_width < 40 )) && popup_width=40
    (( popup_width > width )) && popup_width=$width
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

# Devpods use the same package installation and OMZ fzf integration as laptops.
# Keep network installation out of shell startup; run `dotfiles install` first.
