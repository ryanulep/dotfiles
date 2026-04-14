# Load our own completion functions
fpath=(~/.zsh/completion /usr/local/share/zsh/site-functions $fpath)
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=($HOME/.docker/completions $fpath)

# Completion paths for lazy-loaded plugins. These must be in fpath before compinit
# so tab-complete works without sourcing the full plugin at startup. docker and kubectl
# completions are already cached by OMZ in $ZSH_CACHE_DIR/completions/ so they don't
# need entries here.
_OMZ="${HOME}/.dotfiles/link/.zgenom/sources/ohmyzsh/ohmyzsh/___/plugins"
fpath=("${_OMZ}/docker-compose" $fpath)
fpath=("${_OMZ}/gradle" $fpath)
fpath=("${_OMZ}/bazel" $fpath)
[[ "$(uname -s)" == "Darwin" ]] && fpath=("${_OMZ}/xcode" $fpath)
unset _OMZ

# Note: compinit is called once by Oh My Zsh (via zgenom) in 20_plugins.sh.
# Calling it here too doubles startup time — fpath additions must come first, which they do.