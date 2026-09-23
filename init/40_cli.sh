# Shared CLI tools, installed explicitly and only when missing.
export PATH="$HOME/bin:$HOME/.fzf/bin:$HOME/.cargo/bin:$HOME/go/bin:$PATH"
mkdir -p "$HOME/bin"

ensure_eget() {
  if ! command -v eget >/dev/null; then
    # The downloader writes to its working directory; don't assume it ran in ~.
    local download_dir
    download_dir=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-eget.XXXXXX") || return
    (cd "$download_dir" && sh "$DOTFILES/scripts/eget.sh") || return
    mv "$download_dir/eget" "$HOME/bin/eget" || return
    rmdir "$download_dir"
  fi
}

# Package managers own these where available; releases fill the Linux gaps.
if ! command -v zoxide >/dev/null; then
  ensure_eget && eget --to "$HOME/bin/zoxide" ajeetdsouza/zoxide || return
fi

# Ubuntu's fzf can predate the full-style UI. Install the release binary during
# setup, preserving Ctrl-R/Ctrl-T and fzf-tab on devpods without network startup.
if ! command -v fzf >/dev/null || ! fzf --help | grep -q -- '--style'; then
  ensure_eget && eget --to "$HOME/bin/fzf" --asset tar.gz junegunn/fzf || return
fi

# Honor the existing Cargo manifest. Installed tools are left alone by install.
# On Linux the distro compiler may be too old for current CLI releases, so use
# static release binaries for these known tools and retain Cargo for other crates.
while IFS= read -r crate || [[ -n "$crate" ]]; do
  [[ -z "$crate" || "$crate" == \#* ]] && continue
  binary=$crate
  case "$crate" in git-delta) binary="delta" ;; jj-cli) binary="jj" ;; ripgrep) binary="rg" ;; esac
  installed_binary=$(command -v "$binary" || true)
  if [[ -z "$installed_binary" || ( "$DOTFILES_ACTION" == upgrade && "$installed_binary" == "$HOME/.cargo/bin/"* ) ]]; then
    release=""
    case "$crate" in
      bat) release=sharkdp/bat ;;
      git-delta) release=dandavison/delta ;;
      jj-cli) release=jj-vcs/jj ;;
      ripgrep) release=BurntSushi/ripgrep ;;
    esac
    if [[ "$OSTYPE" == linux* && -n "$release" ]]; then
      ensure_eget && eget --to "$HOME/bin/$binary" --asset musl --asset .tar.gz --asset '^.sha256' "$release" || return
    else
      cargo install --locked "$crate" || return
    fi
  fi
done < "$DOTFILES/conf/packages/cargo"

# The Go manifest is intentionally readable as standalone `go install` commands.
while read -r tool verb package extra; do
  [[ -z "$tool" || "$tool" == \#* ]] && continue
  [[ "$tool" == go && "$verb" == install && -z "$extra" ]] || {
    e_error "Invalid Go install entry: $tool $verb $package $extra"; return 1;
  }
  binary="${package%@*}"
  binary="${binary##*/}"
  installed_binary=$(command -v "$binary" || true)
  if [[ -z "$installed_binary" || ( "$DOTFILES_ACTION" == upgrade && "$installed_binary" == "${GOBIN:-$HOME/go/bin}/"* ) ]]; then
    go install "$package" || return
  fi
done < "$DOTFILES/conf/packages/go"

# Themes need a bat cache after a fresh install; no rebuild on every shell.
bat cache --build || return
