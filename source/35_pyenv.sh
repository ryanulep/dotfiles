# Keep interpreter selection available without rehashing shims on every shell.
# Run `pyenv rehash` after installing Python command-line executables.
export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
[[ -d "$PYENV_ROOT/bin" ]] && path=("$PYENV_ROOT/bin" $path)
if (( $+commands[pyenv] )); then
  eval "$(pyenv init --no-rehash - zsh)"
fi
