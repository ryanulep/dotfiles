source "${HOME}/.zgenom/zgenom.zsh"

# Tell zgenom not to add its own compinit call — Oh My Zsh already calls it.
# This prevents the double-compinit that costs ~200ms on every startup.
ZGEN_AUTOLOAD_COMPINIT=0

## Pre-work before loading plugins

ZSH_WEB_SEARCH_ENGINES=(
    glean "https://usearch.glean.com/search?q="    # Glean Search
    adoc "https://developer.android.com/s/results?q="    # Android Developer Docs
    bzdoc "https://bazel.build/s/results?q="    # Bazel Docs
    javadoc "https://docs.oracle.com/search/?category=java&product=en%2Fjava&q="
    kdoc "https://kotlinlang.org/docs/home.html?s=full&q="    # Kotlin Docs
)

# Check for plugin and zgenom updates every 7 days
# This does not increase the startup time.
zgenom autoupdate

if ! zgenom saved; then
  echo "Creating a zgenom save"

  zgenom ohmyzsh

  # Setup eget to download core apps
  test -d "$HOME/bin" || mkdir -p "$HOME/bin"
  command -v eget > /dev/null 2>&1 || (bash "$DOTFILES/scripts/eget.sh" && mv $HOME/eget $HOME/bin/)

  # Install core CLI tools using eget
  command -v zoxide > /dev/null 2>&1 || eget ajeetdsouza/zoxide
  command -v bat > /dev/null 2>&1 || eget sharkdp/bat

  # Core Zsh plugins
  zgenom load jandamm/zgenom-ext-eval    # Quickly generate plugins from a command or heredoc.
  zgenom load jandamm/zgenom-ext-release    # Use zgenom and gh to download github releases.
  zgenom load jandamm/zgenom-ext-run    # Run commands in the plugin folder
  zgenom load qoomon/zsh-lazyload    # Lazy load plugins and commands on demand
  zgenom load zsh-users/zsh-completions    # Additional completion definitions for

  # Completions
  zgenom load unixorn/fzf-zsh-plugin
  zgenom ohmyzsh plugins/fzf
  zgenom load aloxaf/fzf-tab
  zgenom load momo-lab/zsh-smartinput    # Inserts corresponding end character when brackets/quotes are inputted

  # Production environment management
  if (( $+commands[docker] )); then
    zgenom ohmyzsh plugins/docker    # Auto-completion and aliases for Docker
  fi
  if (( $+commands[docker-compose] )); then
    zgenom ohmyzsh plugins/docker-compose
  fi
  if (( $+commands[kubectl] )); then
    zgenom ohmyzsh plugins/kubectl
  fi
  zgenom load Cloudstek/zsh-plugin-appup

  # Git plugins
  zgenom ohmyzsh plugins/gh
  zgenom ohmyzsh plugins/git
  if (( $+commands[tig] )); then
    zgenom ohmyzsh plugins/tig
  fi
  if (( $+commands[bat] )); then
    # Use diff-so-fancy for better syntax highlighting and formatting
    # Only works if bat is installed
    zgenom load so-fancy/diff-so-fancy
  fi

  # File management / navigation
  zgenom load raisedadead/zsh-touchplus     # create files with touch including the path
  zgenom ohmyzsh plugins/extract    # Extract compressed files
  # NOTE: zoxide is initialized in 80_zoxide.sh — it must run AFTER every plugin
  # that hooks chpwd_functions, or zoxide's doctor warns on every shell start.
  zgenom load toku-sa-n/zsh-dot-up    # Quickly navigate up directories in the file system

  # Aliases
  zgenom ohmyzsh plugins/common-aliases    # Creates helpful shortcut aliases for many commonly used commands
  zgenom ohmyzsh plugins/alias-finder    # Creates helpful shortcut aliases for many commonly used commands
  zstyle ':omz:plugins:alias-finder' autoload yes
  zstyle ':omz:plugins:alias-finder' longer yes
  zstyle ':omz:plugins:alias-finder' exact yes
  zstyle ':omz:plugins:alias-finder' cheaper yes
  zgenom load brymck/print-alias    # Prints commands with aliases expanded on the CLI

  # Shell enhancements
  zgenom ohmyzsh plugins/iterm2
  zgenom ohmyzsh plugins/colored-man-pages    # Colored man pages
  zgenom ohmyzsh plugins/direnv    # Load and unload environment variables per directory
  zgenom load zsh-users/zsh-autosuggestions    # Suggests commands as you type based on your history and completions
  zgenom ohmyzsh plugins/safe-paste    # Review what was actually pasted before running it
  zgenom ohmyzsh plugins/copyfile    # Puts the contents of a file in your system clipboard
  zgenom ohmyzsh plugins/copybuffer    # Copy the contents of buffer to the clipboard using Ctrl + "O"
  zgenom ohmyzsh plugins/copypath    # Copies the path of given directory or file to the system clipboard
  zgenom ohmyzsh plugins/timer    # Timer plugin to measure the time it takes to run a command
  # history-substring-search must load before fast-syntax-highlighting
  zgenom load zsh-users/zsh-history-substring-search    # Up/down arrows search history by typed prefix
  ## IMPORTANT: zsh-dot-up has to be loaded before fast-syntax-highlighting
  zgenom load zdharma-continuum/fast-syntax-highlighting    # Faster CLI syntax highlighting with more features

  # Productivity
  # zgenom ohmyzsh plugins/web-search    # Search the web from the command line
  zgenom ohmyzsh plugins/jsontools    # Handling JSON data
  if (( $+commands[bazel] )); then
    zgenom ohmyzsh plugins/bazel    # Bazel build system support
  fi

  # Install macOS-only plugins, if needed
  if [[ "$(uname -s)" == "Darwin" ]]; then
    zgenom ohmyzsh plugins/macos
    zgenom ohmyzsh plugins/vscode
    zgenom ohmyzsh plugins/brew
    zgenom load nilsonholger/osx-zsh-completions
  fi

  # Add binaries
  zgenom bin tj/git-extras

  # save all to init script
  zgenom save

  # Compile your zsh files
  zgenom compile "$HOME/.zshrc"

  # You can perform other "time consuming" maintenance tasks here as well.
  # If you use `zgenom autoupdate` you're making sure it gets
  # executed every 7 days.
fi

# Lazy load plugins which are not needed at startup
# SDK and NVM — must be outside the save block to run every startup
lazyload sdk -- 'export SDKMAN_DIR="$HOME/.sdkman" && source "$HOME/.sdkman/bin/sdkman-init.sh"'
lazyload nvm npm node -- 'export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"'
