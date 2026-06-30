# zoxide must be initialized LAST (after oh-my-zsh, all plugins, and iTerm shell
# integration) so its chpwd hook stays at the end of chpwd_functions. Otherwise
# a later plugin resets chpwd_functions and zoxide's doctor warns on every start.
if (( $+commands[zoxide] )); then
  export _ZO_DOCTOR=0  # suppress chpwd ordering warning — handled by load order above
  eval "$(zoxide init zsh --cmd cd)"
fi
