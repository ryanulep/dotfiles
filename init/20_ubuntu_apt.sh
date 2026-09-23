# Ubuntu specific configuration
is_ubuntu || return 1

apt_privilege=()
(( EUID == 0 )) || apt_privilege=(sudo)
"${apt_privilege[@]}" apt-get update || return
apt_packages=()
while IFS= read -r package || [[ -n "$package" ]]; do
  [[ -z "$package" || "$package" == \#* ]] && continue
  # Uber devpods already ship uber-neovim, which conflicts with Ubuntu neovim.
  [[ "$package" == neovim ]] && command -v nvim >/dev/null && continue
  apt_packages+=("$package")
done < "$DOTFILES/conf/packages/apt"
while IFS= read -r package || [[ -n "$package" ]]; do
  [[ -z "$package" || "$package" == \#* ]] && continue
  if apt-cache show "$package" >/dev/null 2>&1; then
    apt_packages+=("$package")
  else
    printf 'Optional package unavailable in this distribution: %s\n' "$package"
  fi
done < "$DOTFILES/conf/packages/apt-optional"
apt_flags=(--assume-yes)
[[ "$DOTFILES_ACTION" == upgrade ]] || apt_flags+=(--no-upgrade)
"${apt_privilege[@]}" apt-get install "${apt_flags[@]}" "${apt_packages[@]}"
