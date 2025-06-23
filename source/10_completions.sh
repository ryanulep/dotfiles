# Load our own completion functions
fpath=(~/.zsh/completion /usr/local/share/zsh/site-functions $fpath)
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=($HOME/.docker/completions $fpath)

# Completion; use cache if updated within 24h
autoload -Uz compinit
if [[ -n $HOME/.zcompdump(#qN.mh+24) ]]; then
  compinit -d $HOME/.zcompdump;
else
  compinit -C;
fi;

# disable zsh bundled function mtools command mcd which causes a conflict
compdef -d mcd