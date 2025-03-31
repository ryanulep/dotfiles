# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# TODO: Add an export for the dotfiles directory

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

zstyle ':omz:update' mode auto      # update automatically without asking

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# Setup Fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Setup environment variables
source ~/dotfiles/zsh/.zsh_variables

# Source the aliases
source ~/dotfiles/zsh/.zsh_aliases

# devpod-fzf
source ~/.zsh/devpod-fzf/devpod-fzf.zsh

# Source custom tmux.conf
tmux source -v ~/dotfiles/.tmux.conf 1> /dev/null

# Is there a way to force installation of packages if they are not already installed?
# Should I add any plugins above?
# How do I customize colors and terminal prompt?
# Why is bat.conf not getting picked up?