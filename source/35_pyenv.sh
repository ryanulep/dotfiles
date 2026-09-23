# Keep interpreter selection available without rehashing shims on every shell.
# Run `pyenv rehash` after installing Python command-line executables.
export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
[[ -d "$PYENV_ROOT/bin" ]] && path=("$PYENV_ROOT/bin" $path)
if (( $+commands[pyenv] )); then
  if _dotfiles_pyenv_init=$(pyenv init --no-rehash - zsh); then
    eval "$_dotfiles_pyenv_init" && _DOTFILES_PYENV_INITIALIZED=1
  fi
  unset _dotfiles_pyenv_init
fi
# A machine-local fallback can check _DOTFILES_PYENV_INITIALIZED, allowing this
# optimization to be reverted without removing the original local setup.
