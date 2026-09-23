# One porcelain snapshot per prompt, computed in a worker. No external plugin.
# Completion updates RPROMPT; the header stays in precmd (fzf rendering fix).
headline-git-snapshot() {
  emulate -L zsh
  local raw line branch='' oid='' rendered='' key code
  local -a fields
  local -A counts=(STAGED 0 CHANGED 0 UNTRACKED 0 BEHIND 0 AHEAD 0 STASHED 0 CONFLICTS 0 CLEAN 1)
  raw=$(GIT_OPTIONAL_LOCKS=0 command git status --porcelain=v2 --branch --show-stash 2>/dev/null) || {
    printf '%s\0%s\0%s\0' "$PWD" "" ""
    return
  }
  for line in "${(@f)raw}"; do
    fields=(${(s: :)line})
    case "$line" in
      '# branch.head '*) branch=${line#\# branch.head } ;;
      '# branch.oid '*) oid=${line#\# branch.oid } ;;
      '# branch.ab '*) counts[AHEAD]=${fields[3]#+}; counts[BEHIND]=${fields[4]#-} ;;
      '# stash '*) counts[STASHED]=${fields[3]} ;;
      '1 '*|'2 '*)
        code=$fields[2]
        [[ $code[1] != . ]] && (( counts[STAGED]++ ))
        [[ $code[2] != . ]] && (( counts[CHANGED]++ ))
        ;;
      'u '*) (( counts[CONFLICTS]++ )) ;;
      '? '*) (( counts[UNTRACKED]++ )) ;;
    esac
  done
  [[ $branch == '(detached)' ]] && branch=":${oid[1,8]}"
  for key in STAGED CHANGED UNTRACKED BEHIND AHEAD STASHED CONFLICTS; do
    if (( counts[$key] )); then
      counts[CLEAN]=0
      [[ -n $rendered ]] && rendered+='|'
      rendered+="$counts[$key]${HL_GIT_STATUS_SYMBOLS[$key]}"
    fi
  done
  (( counts[CLEAN] )) && rendered='✔'
  # Escape prompt percent sequences in branch names; never evaluate output.
  branch=${branch//\%/%%}
  # NUL-separated data avoids shell quoting/history-expansion artifacts in an
  # interactive shell (notably an unwanted backslash before the '!' marker).
  printf '%s\0%s\0%s\0' "$PWD" "$branch" "$rendered"
}

headline-git-close() {
  if [[ -n ${_HL_GIT_FD:-} ]]; then
    zle -F "$_HL_GIT_FD" 2>/dev/null
    exec {_HL_GIT_FD}<&-
    unset _HL_GIT_FD
  fi
}

headline-git-ready() {
  emulate -L zsh
  local directory branch status_text
  # A closed writer may report hup while its final line is still readable.
  if [[ -z $2 || $2 == hup ]] &&
      IFS= read -r -d '' -u "$1" directory &&
      IFS= read -r -d '' -u "$1" branch &&
      IFS= read -r -d '' -u "$1" status_text; then
    if [[ $directory == "$PWD" ]]; then
      _HL_GIT_BRANCH=$branch
      _HL_GIT_STATUS=$status_text
      # Build color escapes outside ${var:+...}: their braces terminate Zsh's
      # parameter expansion early and otherwise leak stray braces into RPROMPT.
      _HL_GIT_PROMPT=''
      if [[ -n $_HL_GIT_BRANCH ]]; then
        _HL_GIT_PROMPT="%F{cyan} $_HL_GIT_BRANCH%f"
        [[ -z $_HL_GIT_STATUS ]] || _HL_GIT_PROMPT+=" [%F{magenta}$_HL_GIT_STATUS%f]"
      fi
      [[ -o zle ]] && zle .reset-prompt
    fi
  fi
  headline-git-close
}

headline-git-refresh() {
  # Changing directory must never display the previous repository's branch.
  if [[ ${_HL_GIT_PWD:-} != "$PWD" ]]; then
    _HL_GIT_BRANCH=''
    _HL_GIT_STATUS=''
    _HL_GIT_PROMPT=''
    _HL_GIT_PWD=$PWD
  fi
  # At most one query in flight; discard results for a previous directory.
  [[ -n ${_HL_GIT_FD:-} ]] && return
  exec {_HL_GIT_FD}< <(headline-git-snapshot)
  zle -F "$_HL_GIT_FD" headline-git-ready
}

# Close an existing descriptor on re-source before replacing hooks.
headline-git-close
autoload -Uz add-zsh-hook
add-zsh-hook precmd headline-git-refresh
add-zsh-hook zshexit headline-git-close
