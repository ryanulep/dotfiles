# Configuration verification — September 23, 2026

Baseline: `f0cbc47`. Changes were developed in an isolated Git worktree so the
live tmux autoreloader could not load incomplete edits.

## Regression checks

`scripts/check-config` passed all 22 behavioral tests, with no skips, on:

| Environment | tmux | fzf selected by the new PATH | Neovim |
| --- | --- | --- | --- |
| macOS laptop | 3.7c | 0.74.3 | Existing LazyVim installation |
| Go devpod, Debian 12 | 3.3a | 0.74.3 | 0.12.0 |
| Web devpod, Debian 12 | 3.3a | 0.74.4 | 0.12.0 |

Devpod tests ran in temporary directories. Missing navigator/theme dependencies
were copied into those test directories, not installed into the active dotfiles.
The same tests cover both absent-plugin startup and installed-theme startup.

The suite checks history inclusion/exclusion, fzf options and pane sizing,
bounded previews, exact clipboard bytes, Linux theme selection, repeatable
offline linking, preservation of provided Neovim, optional SDK loaders, initial
TPM installation without a server, async prompt state/rendering, editor signs,
resource warning colors, attached-client navigation, restored pane geometry,
project session names, task arguments/failure codes, and iTerm profile generation.
Migration checks also cover legacy commands after zgenom deletes its generated
bin links and dynamic warning colors in the fully assembled status bar.

Additional checks:

- Shell syntax and ShellCheck on new Bash helpers and package-install scripts.
- Actual interactive Zsh startup and asynchronous right-prompt rendering.
- Full existing LazyVim startup using the isolated configuration.
- Actual interactive Tig graph rendering and clean exit.
- Debian package resolution using `apt-get -s`; no packages changed on devpods.
- Mocked Cargo/Go/release installation dispatch and Homebrew install flags.
- Existing package-managed and legacy-only git-extras commands remain available.

## Measured responsiveness

Ten-run `hyperfine` comparison, with two warmups, in the same small repository:

| Foreground prompt rendering | Mean | Standard deviation |
| --- | --- | --- |
| Original | 128.9 ms | 5.1 ms |
| New asynchronous Git prompt | 32.4 ms | 3.1 ms |

The foreground portion is about 4× faster. Git collection now happens separately
and refreshes the right prompt when complete; these numbers are not a claim of
4× faster Git queries or overall development speed.

`pyenv init --no-rehash` measured 63–77 ms versus approximately 275 ms for the
original machine-local initializer. A local fallback guard preserves the original
initializer if the shared optimization is reverted.

## tmux defects reproduced

1. Plugin path initialization happened after theme/module loading. On a fresh
   server this produced exit 127 and missing `./custom_modules` files. Both the
   installed and missing-plugin cases now load without those errors.
2. A restored 117×43 layout remained inside a 189×47 window, producing the dotted
   margin. Tests repair one- and two-pane layouts while preserving panes and
   inherited sizing policy. Session restoration remains enabled.
3. Older tmux did not expand the entire `update-environment` array in a format.
   Repeated config loads now preserve one `COLORFGBG` registration on both versions.

## Scope and limitations

These checks found no remaining regressions in the tested behavior. They do not
prove every application interaction. A full reinstall of the laptop's GUI apps
or the devpods' package sets was not performed; installer dispatch and package
resolution were checked without replacing the running environments.

While installing the local validation tools, Homebrew automatically cleaned
download caches and older keg versions. Active Python 3.14.7, pyenv's Python
3.11.15, and the existing mdformat environment remained operational. Setup now
disables this automatic cleanup so it remains an explicit maintenance operation.
