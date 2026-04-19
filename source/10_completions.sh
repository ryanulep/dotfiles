# Load our own completion functions
fpath=(~/.zsh/completion /usr/local/share/zsh/site-functions $fpath)
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=($HOME/.docker/completions $fpath)

# Note: compinit is called once by Oh My Zsh (via zgenom) in 20_plugins.sh.
# Calling it here too doubles startup time — fpath additions must come first, which they do.