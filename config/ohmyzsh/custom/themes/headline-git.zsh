# One porcelain snapshot per prompt, computed in a worker. No external plugin.
# Completion updates RPROMPT; the header stays in precmd (fzf rendering fix).
headline-git-snapshot() {
  emulate -L zsh
  local raw line branch='' oid='' rendered='' key code
  local -a fields
  local -A counts=(STAGED 0 CHANGED 0 UNTRACKED 0 BEHIND 0 AHEAD 0 STASHED 0 CONFLICTS 0 CLEAN 1)
  raw=$(GIT_OPTIONAL_LOCKS=0 command git status --porcelain=v2 --branch --show-stash 2>/dev/null) || {
    print -r -- "${(qqq)PWD} \"\" \"\""
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
  print -r -- "${(qqq)PWD} ${(qqq)branch} ${(qqq)rendered}"
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
  local record
  local -a fields
  # A closed writer may report hup while its final line is still readable.
  if [[ -z $2 || $2 == hup ]] && IFS= read -r -u "$1" record; then
    fields=(${(z)record})
    fields=("${(@Q)fields}")
    if [[ $fields[1] == "$PWD" ]]; then
      _HL_GIT_BRANCH=$fields[2]
      _HL_GIT_STATUS=$fields[3]
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
