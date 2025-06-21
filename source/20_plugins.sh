source "${HOME}/.zgenom/zgenom.zsh"

## Pre-work before loading plugins

ZSH_WEB_SEARCH_ENGINES=(
    glean "https://usearch.glean.com/search?q="  # Glean Search
    adoc "https://developer.android.com/s/results?q="  # Android Developer Docs
    bzdoc "https://bazel.build/s/results?q="  # Bazel Docs
    javadoc "https://docs.oracle.com/search/?category=java&product=en%2Fjava&q="
    kdoc "https://kotlinlang.org/docs/home.html?s=full&q="  # Kotlin Docs
)

# Check for plugin and zgenom updates every 7 days
# This does not increase the startup time.
# zgenom autoupdate

if ! zgenom saved; then
  echo "Creating a zgenom save"

  # Oh-My-Zsh base library
  zgenom ohmyzsh

  # Check for plugin and zgenom updates every 7 days
  zgenom load unixorn/autoupdate-zgenom

  # Completions
  zgenom load unixorn/fzf-zsh-plugin
  zgenom ohmyzsh plugins/fzf
  zgenom ohmyzsh plugins/command-not-found  # Provide suggested packages to be installed if a command cannot be found
  zgenom load zsh-users/zsh-autosuggestions
  zgenom load zsh-users/zsh-completions

  # Production environment management
  zgenom ohmyzsh plugins/docker  # Auto-completion and aliases for Docker
  zgenom ohmyzsh plugins/docker-compose
  zgenom ohmyzsh plugins/kubectl
  zgenom ohmyzsh plugins/kubectx
  zgenom ohmyzsh plugins/gcloud
  zgenom ohmyzsh plugins/aws
  zgenom load Cloudstek/zsh-plugin-appup

  # Git plugins
  zgenom ohmyzsh plugins/gh
  zgenom ohmyzsh plugins/git
  zgenom ohmyzsh plugins/github
  zgenom ohmyzsh plugins/git-prompt
  zgenom ohmyzsh plugins/tig
  zgenom load so-fancy/diff-so-fancy

  # File management
  zgenom load raisedadead/zsh-touchplus  # create files with touch including the path
  zgenom ohmyzsh plugins/wd  # Jump to custom directories in zsh without using `cd`
  zgenom ohmyzsh plugins/extract  # Extract compressed files
  zgenom ohmyzsh plugins/colorize  # Provides syntax highlighting for files
  zgenom ohmyzsh plugins/zoxide  # Smarter cd command

  # Shell enhancements
  zgenom ohmyzsh plugins/iterm2
  zgenom ohmyzsh plugins/tmux
  zgenom ohmyzsh plugins/thefuck  # Corrects mistyped commands
  zgenom load zsh-users/zsh-syntax-highlighting  # Provides CLI syntax highlighting
  zgenom ohmyzsh plugins/aliases  # Lists shortcuts available based on installed plugins
  zgenom ohmyzsh plugins/alias-finder  # Searches defined aliases and outputs any that match the command inputted
  zgenom ohmyzsh plugins/safe-paste  # Review what was actually pasted before running it
  zgenom ohmyzsh plugins/last-working-dir  # Track the last used working directory and automatically jump into it for new shells
  zgenom ohmyzsh plugins/common-aliases  # Creates helpful shortcut aliases for many commonly used commands
  zgenom ohmyzsh plugins/zsh-interactive-cd  # Interactive way to change directories in zsh using fzf
  zgenom ohmyzsh plugins/copyfile
  zgenom ohmyzsh plugins/copybuffer  # Copy the contents of buffer to the clipboard using Ctrl + "O"
  zgenom ohmyzsh plugins/copypath
  zgenom load djui/alias-tips  # Warns you when you have an alias for the command you just typed
  zgenom ohmyzsh plugins/colored-man-pages  # Colored man pages
  zgenom ohmyzsh plugins/timer  # Timer plugin to measure the time it takes to run a command

  # Productivity
  zgenom ohmyzsh plugins/web-search  # Search the web from the command line
  zgenom ohmyzsh plugins/bazel  # Bazel build system support
  zgenom ohmyzsh plugins/jsontools  # Handling JSON data
  
  # Core Zsh plugins
  zgenom load jandamm/zgenom-ext-eval  # Quickly generate plugins from a command or heredoc.
  zgenom load jandamm/zgenom-ext-release  # Use zgenom and gh to download github releases.
  zgenom load jandamm/zgenom-ext-run  # Run commands in the plugin folder
  zgenom load qoomon/zsh-lazyload
  zgenom load aloxaf/fzf-tab

  # Install macOS only plugins, if needed
  [[ "$(uname -s)" = Darwin ]] && zgenom ohmyzsh plugins/macos
  [[ "$(uname -s)" = Darwin ]] && zgenom ohmyzsh plugins/vscode
  [[ "$(uname -s)" = Darwin ]] && zgenom ohmyzsh plugins/brew
  [[ "$(uname -s)" = Darwin ]] && zgenom ohmyzsh plugins/xcode
  [[ "$(uname -s)" = Darwin ]] && zgenom load nilsonholger/osx-zsh-completions

  # Add binaries
  zgenom bin tj/git-extras

  # Setup eget to download core apps
  test -d "$HOME/bin" || mkdir -p "$HOME/bin"
  command -v eget > /dev/null 2>&1 || (bash "$DOTFILES/scripts/eget.sh" && mv $HOME/eget $HOME/bin/)

  # Install core apps using eget
  command -v zoxide > /dev/null 2>&1 || eget ajeetdsouza/zoxide
  command -v bat > /dev/null 2>&1 || eget sharkdp/bat
  command -v direnv > /dev/null 2>&1 || eget direnv/direnv
  command -v rg > /dev/null 2>&1 || eget BurntSushi/ripgrep
  command -v fd > /dev/null 2>&1 || eget sharkdp/fd
  command -v autoenv > /dev/null 2>&1 || eget hyperupcall/autoenv

  # Install plugins required after the core apps are installed
  zgenom ohmyzsh plugins/direnv  # Load and unload environment variables per directory
  zgenom ohmyzsh plugins/autoenv  # Automatically load and unload environment variables per directory

  lazyload sdk -- 'export SDKMAN_DIR="$HOME/.sdkman" && source "$HOME/.sdkman/bin/sdkman-init.sh"'
  lazyload nvm npm node -- 'export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"'

  zgenom eval --name zoxide <<(zoxide init zsh --cmd cd)
  zgenom eval --name wtf $(thefuck --alias wtf)

  # save all to init script
  zgenom save

  # Compile your zsh files
  zgenom compile "$HOME/.zshrc"

  # You can perform other "time consuming" maintenance tasks here as well.
  # If you use `zgenom autoupdate` you're making sure it gets
  # executed every 7 days.
fi