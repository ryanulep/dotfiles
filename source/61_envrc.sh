## Bat (https://github.com/sharkdp/bat)
export BAT_CONFIG_PATH="$HOME/.config/bat/config"
# If delta is installed, use delta by default.
BATDIFF_USE_DELTA=true

# To opt in to Homebrew analytics, `unset` this in ~/.zshrc.local .
export HOMEBREW_NO_ANALYTICS=1

[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local || true