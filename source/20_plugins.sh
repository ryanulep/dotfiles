source "${HOME}/.zgenom/zgenom.zsh"

# Check for plugin and zgenom updates every 7 days
# This does not increase the startup time.
# zgenom autoupdate

if ! zgenom saved; then
  zgenom ohmyzsh

  # Completions
  zgenom load unixorn/fzf-zsh-plugin
  zgenom ohmyzsh plugins/fzf
  zgenom ohmyzsh plugins/command-not-found  # Provide suggested packages to be installed if a command cannot be found
  zgenom ohmyzsh plugins/bazel
  zgenom load zsh-users/zsh-autosuggestions
  zgenom load zsh-users/zsh-completions

  # Production environment management
  zgenom ohmyzsh plugins/docker  # auto-completion and aliases for docker.
  zgenom ohmyzsh plugins/docker-compose
  zgenom ohmyzsh plugins/gcloud
  zgenom ohmyzsh plugins/aws
  zgenom ohmyzsh plugins/kubectl
  zgenom ohmyzsh plugins/kubectx

  # Git plugins
  zgenom ohmyzsh plugins/gh
  zgenom ohmyzsh plugins/git
  zgenom ohmyzsh plugins/github
  zgenom ohmyzsh plugins/arcanist

  # System enhancements
  zgenom ohmyzsh plugins/iterm2
  zgenom ohmyzsh plugins/tmux
  zgenom ohmyzsh plugins/jira
  zgenom ohmyzsh plugins/extract  # Extract compressed files
  zgenom ohmyzsh plugins/aliases  # Lists shortcuts available based on installed plugins
  zgenom ohmyzsh plugins/alias-finder  # Searches defined aliases and outputs any that match the command inputted
  zgenom ohmyzsh plugins/colorize  # Provides syntax highlighting for files
  zgenom load zsh-users/zsh-syntax-highlighting  # Provides CLI syntax highlighting
  zgenom ohmyzsh plugins/zoxide  # Smarter cd command
  zgenom ohmyzsh plugins/safe-paste  # Review what was actually pasted before running it
  zgenom ohmyzsh plugins/last-working-dir  # Track the last used working directory and automatically jump into it for new shells
  zgenom ohmyzsh plugins/thefuck  # Fix common command line mistakes

  # Random Extras
  zgenom ohmyzsh plugins/jsontools  # Handling JSON data
  zgenom ohmyzsh plugins/colored-man-pages  # Colored man pages
  zgenom ohmyzsh plugins/copyfile
  zgenom ohmyzsh plugins/copypath
  zgenom load djui/alias-tips  # Warns you when you have an alias for the command you just typed

  zgenom load jandamm/zgenom-ext-eval
  zgenom load jandamm/zgenom-ext-release
  zgenom load jandamm/zgenom-ext-run
  zgenom load qoomon/zsh-lazyload

  # Install macOS only plugins, if needed
  [[ "$(uname -s)" = Darwin ]] && zgenom ohmyzsh plugins/macos
  [[ "$(uname -s)" = Darwin ]] && zgenom ohmyzsh plugins/vscode
  [[ "$(uname -s)" = Darwin ]] && zgenom ohmyzsh plugins/brew

  zgenom load aloxaf/fzf-tab

  # Add binaries
  zgenom bin tj/git-extras

  # Setup eget to download core apps
  test -d "$HOME/bin" || mkdir -p "$HOME/bin"
  command -v eget > /dev/null 2>&1 || (bash "$DOTFILES/scripts/eget.sh" && mv $HOME/eget $HOME/bin/)

  # Install core apps
  command -v zoxide > /dev/null 2>&1 || eget ajeetdsouza/zoxide
  # command -v thefuck > /dev/null 2>&1 || eget nvbn/thefuck
  command -v bat > /dev/null 2>&1 || eget sharkdp/bat
  command -v fd > /dev/null 2>&1 || eget sharkdp/fd

  lazyload sdk -- 'export SDKMAN_DIR="$HOME/.sdkman" && source "$HOME/.sdkman/bin/sdkman-init.sh"'
  lazyload nvm npm node -- 'export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"'

  zgenom eval --name zoxide <<(zoxide init zsh)
  # eval $(thefuck --alias wtf)

  # save all to init script
  zgenom save

  # Compile your zsh files
  zgenom compile "$HOME/.zshrc"

  # You can perform other "time consuming" maintenance tasks here as well.
  # If you use `zgenom autoupdate` you're making sure it gets
  # executed every 7 days.
fi