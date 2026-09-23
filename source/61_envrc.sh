export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

## Bat (https://github.com/sharkdp/bat)
if (( $+commands[bat] )); then
  export BAT_CONFIG_PATH="$XDG_CONFIG_HOME/bat/config"
  export BAT_THEME_LIGHT="Catppuccin Latte"
  export BAT_THEME_DARK="Catppuccin Mocha"
  if [[ -z ${BAT_THEME:-} ]]; then
    if [[ $OSTYPE == darwin* ]]; then
      # Modern Homebrew bat follows appearance changes without a subprocess.
      export BAT_THEME=auto:system
    else
      # auto:system is macOS-only; older devpod bat understands explicit names.
      _bat_background=${COLORFGBG##*;}
      if [[ $_bat_background == <-> ]] && (( _bat_background >= 8 )); then
        export BAT_THEME="$BAT_THEME_LIGHT"
      else
        export BAT_THEME="$BAT_THEME_DARK"
      fi
      unset _bat_background
    fi
  fi
fi
if (( $+commands[delta] )); then
  # If delta is installed, use delta by default.
  export BATDIFF_USE_DELTA=true
fi

# XDG_CONFIG_HOME is initialized before deriving application config paths above.

export TIMER_THRESHOLD=2

# To opt in to Homebrew analytics, `unset` this in ~/.zshrc.local .
export HOMEBREW_NO_ANALYTICS=1

if [[ -f ~/.zshenv.local ]]; then
	source ~/.zshenv.local
fi
