# Ryan's dotfiles

## Install

For the initial install:

#### Ubuntu

```sh
bash -c "$(wget -qO- https://raw.github.com/ryanulep/dotfiles/main/bin/dotfiles)" && source ~/.zshrc
```

#### macOS

```sh
bash -c "$(curl -fsSL https://raw.github.com/ryanulep/dotfiles/main/bin/dotfiles)" && source ~/.zshrc
```

#### or

```sh
git clone https://github.com/ryanulep/dotfiles.git ~/.dotfiles --recursive
~/.dotfiles/bin/dotfiles install
source ~/.zshrc
```

To update the dotfiles:
```sh
dotfiles
```

The default `update` action fast-forwards the repository and applies configuration.
It does not upgrade applications. On an existing checkout, use `dotfiles install`
once to install missing dependencies.

| Command | Purpose |
| --- | --- |
| `dotfiles link` | Apply the current checkout, offline, with backups of replaced files |
| `dotfiles install` | Install missing platform packages, CLI tools, and tmux plugins |
| `dotfiles upgrade` | Explicitly upgrade dependencies; Homebrew cleanup remains separate |
| `dotfiles check` | Run syntax and behavior checks without reloading the calling shell |
| `dotfiles-tmux-plugins` | Repair missing tmux plugins and reload, or prepare a fresh server |

Open a new shell after applying changes. Plugin settings are evaluated on every
startup; changes to the plugin declaration file invalidate zgenom's saved list.
When upgrading from a cache created before this mechanism existed, run
`zgenom reset` once, then open a new shell.

## Devpods and Linux

Devpod creation should run `~/.dotfiles/bin/dotfiles install`; restart tasks should
run `~/.dotfiles/bin/dotfiles link`. Neither requires `yes` or an interactive TTY.
The platform's repository-update mechanism can fetch changes separately.

- Preserve `uber-neovim` and existing managed Go/Rust installations.
- Use `fd` or Debian's `fdfind`; both are supported by the pickers.
- Prefer an existing `~/.fzf/bin/fzf` before plugins load. Setup installs a modern
  release when the distro fzf is too old for the configured UI.
- Bat uses explicit Catppuccin themes on Linux and system appearance on macOS.
  Remove old devpod tasks that rewrite `config/bat/config`; they are unnecessary.
- Clipboard operations use tmux forwarding or OSC 52 on headless connections.
  The outer terminal must allow clipboard writes.
- Rust CLI tools use static Linux releases when distro compilers are too old.
  The Cargo and Go manifests remain the list of required tools.

Noninteractive package setup is supported on Debian/Ubuntu. On other Linux
distributions, install the equivalent prerequisites before linking configuration.
LazyVim requires a recent Neovim; the tested devpod image provides 0.12.

## Daily workflows

| Action | Shortcut/command |
| --- | --- |
| Search command history / files / directories | Ctrl-R / Ctrl-T / Alt-C |
| Preview completion candidates | Tab; fzf-tab owns its own layout |
| Switch/create a project or worktree session | `tmux-project` or `tmux-project /path` |
| Switch Neovim splits and tmux panes | Ctrl-h/j/k/l |
| Clear the shell when tmux captures Ctrl-L | tmux prefix, then Ctrl-L |
| Select text, paths, or URLs from pane output | tmux prefix, then lowercase `e` |
| Fuzzy tmux actions / key discovery | tmux prefix, then `F` / Space |
| Save / restore sessions | tmux prefix, then Ctrl-S / Ctrl-R |
| Reload the light/dark theme | tmux prefix, then `T` |
| Stage changes and resolve conflicts | `lg` (lazygit) |
| Investigate history / blame | `tig --all` / `tig blame path/to/file` |
| Copy piped text locally or from a devpod | `command | dotfiles-copy` |

The prompt's Git segment lives on the right of the command line and updates from
one background status snapshot. Directory changes immediately clear old repository
state. CPU/RAM warnings remain in tmux, but reuse percentage queries and refresh
every 15 seconds. Session names identify projects.

Define explicit project tasks in a repository's `.dotfiles-tasks.json`:

```json
{
  "test": ["./scripts/test"],
  "build": ["./scripts/build"]
}
```

Run `project-task` to choose with fzf, or `project-task test -- extra-argument`.
Commands are argument arrays, run at the configuration file's directory, and are
never executed merely by entering a repository. To capture failures for Neovim:

```sh
project-task --log /tmp/project-test.log test
```

Then use `:cfile /tmp/project-test.log` for compiler-style diagnostics. Existing
Neovim task/terminal workflows and `:make` are not overridden.

## Appearance and machine-local settings

`dotfiles-iterm --install` installs an additive **Dotfiles** Dynamic Profile.
Select it in iTerm Profiles; existing profiles remain available. It uses the
tracked Catppuccin palettes, a 120×35 starting window, and 50,000 scrollback lines.
Left Option sends Meta; right Option remains available for international text.

AeroSpace owns desktop tiling shortcuts (Alt-h/j/k/l); tmux owns Ctrl-h/j/k/l.
Hammerspoon remains installed for other automation. Avoid assigning overlapping
window-management shortcuts in both tools. Installing AeroSpace does not start it.

Keep credentials, machine paths, and overrides in `~/.zshrc.local`,
`~/.aliases.local`, `~/.tmux.conf.local`, and `~/.gitconfig.local`. Git local
overrides load last. The fallback Vim configuration remains available.

If a local file already initializes pyenv, retain it as a reversible fallback:

```zsh
if [[ -z ${_DOTFILES_PYENV_INITIALIZED:-} ]]; then
  eval "$(pyenv init - zsh)"
fi
```

The shared initialization uses `--no-rehash`; run `pyenv rehash` after installing
Python command-line executables. The marker is not inherited by child shells.

## Verification and rollback

`scripts/check-config` runs syntax checks and behavioral tests in temporary
directories and isolated tmux servers. It covers startup without plugins,
reloading, restored window sizing, history filters, clipboard bytes, prompt
state, editor signs, project tasks, and repeatable offline installation.

Use focused `git revert <commit>` operations for rollback, then `dotfiles link`
and open a new shell. Re-run `dotfiles-tmux-plugins` after changing plugin
declarations. Configuration backups live under `backups/`.

Keep the previously restored mouse plugin and both fzf integrations: their
removal broke behavior in the July 2026 history. Ranger's VCS/image-preview
choices and Go's syntax-only editor support are also deliberate.

# Other Dotfiles repos to look at:
- https://github.com/tyvsmith/dotfiles
- https://github.com/jbarr21/dotfiles
- https://github.com/holman/dotfiles
- https://github.com/thoughtbot/dotfiles
- https://github.com/mathiasbynens/dotfiles
- https://github.com/skwp/dotfiles

# Good Zinit References
- https://github.com/Aloxaf/dotfiles/blob/master/zsh/.config/zsh/zshrc.zsh#L114-L120
- https://gitlab.com/jjzmajic/ansible-dots/-/blob/master/zsh/zshrc
- https://git.sr.ht/~seirdy/dotfiles/tree/master/.config/shell_common/zsh/zinit.zsh
- https://github.com/kdeldycke/dotfiles/blob/main/dotfiles/.zshrc
- https://github.com/crivotz/dot_files/blob/master/linux/zplugin/zshrc
- https://github.com/zdharma/zinit-configs/blob/master/psprint/zshrc.zsh
