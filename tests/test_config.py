"""Behavioral checks for the configuration fixes; fixtures never use the live server."""
import base64
import json
import os
from pathlib import Path
import pty
import re
import shutil
import subprocess
import tempfile
import time
import unittest

ROOT = Path(__file__).resolve().parents[1]


def run(*argv, input=None, env=None, cwd=ROOT, check=True):
    return subprocess.run(
        argv, input=input, text=True, capture_output=True, cwd=cwd,
        env={**os.environ, **(env or {})}, check=check, timeout=30,
    )


class ShellTests(unittest.TestCase):
    def test_bookmark_selection_preserves_url(self):
        with tempfile.TemporaryDirectory(prefix="dotfiles-bookmarks-") as directory:
            bookmarks = Path(directory) / "Bookmarks"
            url = "https://example.invalid/path%20with%20spaces?a=1&b=2"
            bookmarks.write_text(json.dumps({"roots": {"bar": {
                "name": "Bookmarks", "children": [{"name": "A useful page", "url": url}]
            }}}))
            result = run("zsh", "-fc", r'''
source source/50_fzf_utils.sh
fzf() { command cat; }
open() { printf '%s\n' "$1"; }
b
''', env={"CHROME_BOOKMARKS_FILE": str(bookmarks)})
            self.assertEqual(result.stdout.strip(), url)

    def test_tpm_install_without_a_running_server(self):
        if not shutil.which("tmux"):
            self.skipTest("tmux is not installed")
        with tempfile.TemporaryDirectory(prefix="dotfiles-tpm-test-") as directory:
            plugins = Path(directory) / "plugins"
            installer = plugins / "tpm/bin/install_plugins"
            installer.parent.mkdir(parents=True)
            installer.write_text(
                "#!/bin/sh\nset -e\n"
                'tmux show-environment -g TMUX_PLUGIN_MANAGER_PATH\n'
                'test -z "$(tmux display-message -p \'#{session_name}\')"\n'
                'printf "INSTALL_TEST_OK\\n"\n'
            )
            installer.chmod(0o755)
            result = run("bash", "bin/dotfiles-tmux-plugins", env={
                "DOTFILES": str(ROOT), "TMUX_PLUGIN_MANAGER_PATH": str(plugins),
                "TMUX": f"{directory}/not-running,0,0",
            })
            self.assertIn("INSTALL_TEST_OK", result.stdout)
            self.assertIn("ready for the next tmux start", result.stdout)

    def test_history(self):
        run("zsh", "-fc", r'''
source source/50_history.sh
for line in "ls" "ls -la" "git status --short" "cd space here" "tmux new -s work"; do
  [[ $line == ${~HISTORY_IGNORE} ]] || exit 1
done
for line in "make test" "git commit -m fix" "bazel test //..." "jj new" "lsusb"; do
  [[ $line != ${~HISTORY_IGNORE} ]] || exit 2
done
[[ $options[sharehistory] == on && $options[incappendhistory] == off ]]
''')

    def test_fzf_widgets_and_resize(self):
        run("zsh", "-fc", r'''
autoload -Uz add-zsh-hook
DOTFILES=$PWD
source source/01_path.sh
source source/05_fzf.sh
[[ $FZF_DEFAULT_OPTS != *ctrl-o* ]] || exit 1
if (( $+commands[fd] || $+commands[fdfind] )); then
  [[ $FZF_CTRL_T_COMMAND == $FZF_DEFAULT_COMMAND ]] || exit 2
  [[ $FZF_ALT_C_COMMAND == *"--type d"* ]] || exit 3
fi
tmux() { print -u2 "Unexpected tmux invocation during resize"; return 99; }
TMUX=test COLUMNS=30
_fzf_tab_resize
zstyle -a ':fzf-tab:*' popup-min-size dimensions
[[ $dimensions[1] == 30 ]] || exit 4
COLUMNS=160
_fzf_tab_resize
zstyle -a ':fzf-tab:*' popup-min-size dimensions
[[ $dimensions[1] == 120 ]] || exit 5
_fzf_tab_resize
if (( $+commands[fzf] )); then
  print -r -- example | fzf --filter=example >/dev/null || exit 6
fi
''')

    def test_large_preview_is_bounded(self):
        with tempfile.TemporaryDirectory(prefix="dotfiles-preview-") as directory:
            large = Path(directory) / "large.json"
            large.write_bytes(b" " * 1048577)
            result = run("zsh", "bin/fzf-tab-preview", str(large))
            self.assertIn("Preview omitted", result.stdout)

    def test_clipboard_byte_round_trip(self):
        text = "100% complete \\\\ λ\nfile with spaces\n"
        result = run("bash", "bin/dotfiles-copy", "--emit", input=text)
        self.assertTrue(result.stdout.startswith("\033]52;c;"))
        self.assertEqual(base64.b64decode(result.stdout[7:-1]).decode(), text)

    def test_linux_bat_theme_without_system_flags(self):
        result = run("zsh", "-fc", r'''
XDG_CONFIG_HOME=$PWD/config
OSTYPE=linux-gnu
unset BAT_THEME
COLORFGBG='0;15'
source source/61_envrc.sh
[[ $BAT_THEME == 'Catppuccin Latte' ]] || exit 1
unset BAT_THEME
COLORFGBG='15;0'
source source/61_envrc.sh
[[ $BAT_THEME == 'Catppuccin Mocha' ]]
''')
        self.assertEqual(result.returncode, 0)
        self.assertNotIn("--theme-light", (ROOT / "config/bat/config").read_text())

    def test_offline_link_is_repeatable(self):
        with tempfile.TemporaryDirectory(prefix="dotfiles-link-") as directory:
            target = Path(directory) / "target"
            env = {"DOTFILES": str(ROOT), "DOTFILES_TARGET": str(target),
                   "XDG_CONFIG_HOME": str(target / ".config")}
            run("bash", "bin/dotfiles", "link", input="", env=env)
            run("bash", "bin/dotfiles", "link", input="", env=env)
            self.assertEqual((target / ".zshrc").resolve(), ROOT / "link/.zshrc")
            self.assertEqual((target / ".config/nvim").resolve(), ROOT / "config/nvim")
            self.assertEqual((target / ".gitconfig").read_bytes(),
                             (ROOT / "copy/.gitconfig").read_bytes())

    def test_apt_preserves_existing_neovim(self):
        result = run("bash", "-c", r'''
is_ubuntu() { return 0; }
sudo() { "$@"; }
apt-get() { printf '%s\n' "$*"; }
apt-cache() { return 1; }
nvim() { :; }
source init/20_ubuntu_apt.sh
''', env={"DOTFILES": str(ROOT), "DOTFILES_ACTION": "install"})
        install = next(line for line in result.stdout.splitlines() if line.startswith("install "))
        self.assertIn("--no-upgrade", install)
        self.assertNotIn("neovim", install)
        self.assertIn("fd-find", install)

    def test_optional_loaders_preserve_existing_binary(self):
        # Execute the actual guards with a recorder, without loading/updating plugins.
        source = (ROOT / "source/20_plugins.sh").read_text()
        guards = source[source.index('export SDKMAN_DIR='):]
        result = run("zsh", "-fc", 'lazyload() { print UNEXPECTED; }\n' + guards,
                     env={"SDKMAN_DIR": "/nonexistent/dotfiles-sdk",
                          "NVM_DIR": "/nonexistent/dotfiles-nvm"})
        self.assertNotIn("UNEXPECTED", result.stdout)


class PromptTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="dotfiles-git-")
        self.repo = Path(self.temp.name)
        run("git", "init", "-q", "-b", "audit", cwd=self.repo)
        run("git", "-c", "user.name=Audit", "-c", "user.email=audit@example.invalid",
            "commit", "-qm", "initial", "--allow-empty", cwd=self.repo)

    def tearDown(self):
        self.temp.cleanup()

    def snapshot(self):
        # Emit fields after consuming the real asynchronous descriptor.
        return run("zsh", "-fc", r'''
source "$1/config/ohmyzsh/custom/themes/headline-modern.zsh-theme"
headline-git-refresh
headline-git-ready "$_HL_GIT_FD" hup
print -r -- "$_HL_GIT_BRANCH"
print -r -- "$_HL_GIT_STATUS"
''', "zsh", str(ROOT), cwd=self.repo).stdout.splitlines()

    def test_clean_staged_untracked_and_detached(self):
        self.assertEqual(self.snapshot(), ["audit", "✔"])
        (self.repo / "space here.txt").write_text("a")
        self.assertIn("1?", self.snapshot()[1])
        run("git", "add", "space here.txt", cwd=self.repo)
        self.assertIn("1+", self.snapshot()[1])
        (self.repo / "space here.txt").write_text("changed")
        self.assertIn("1!", self.snapshot()[1])
        self.assertNotIn("\\", self.snapshot()[1])
        run("git", "checkout", "--detach", "-q", cwd=self.repo)
        self.assertTrue(self.snapshot()[0].startswith(":"))

    def test_directory_change_rejects_stale_result(self):
        run("zsh", "-fc", r'''
source "$1/config/ohmyzsh/custom/themes/headline-modern.zsh-theme"
headline-git-refresh
builtin cd /
headline-git-refresh
headline-git-ready "$_HL_GIT_FD" hup
[[ -z $_HL_GIT_BRANCH && -z $_HL_GIT_STATUS ]] || exit 1
headline-git-refresh
headline-git-ready "$_HL_GIT_FD" hup
[[ -z $_HL_GIT_BRANCH && -z $_HL_GIT_STATUS ]]
''', "zsh", str(ROOT), cwd=self.repo)

    def test_prompt_renders_branch_without_parameter_syntax(self):
        result = run("zsh", "-fc", r'''
source "$1/config/ohmyzsh/custom/themes/headline-modern.zsh-theme"
headline-git-refresh
headline-git-ready "$_HL_GIT_FD" hup
headline-precmd >/dev/null
print -P -- "$RPROMPT"
''', "zsh", str(ROOT), cwd=self.repo)
        rendered = re.sub(r"\x1b\[[0-9;]*m", "", result.stdout).strip()
        self.assertEqual(rendered, " audit [✔]")


class WorkflowTests(unittest.TestCase):
    def test_session_names_distinguish_same_named_directories(self):
        with tempfile.TemporaryDirectory(prefix="dotfiles-project-") as directory:
            names = []
            for parent in ["first", "second"]:
                project = Path(directory) / parent / "same name"
                project.mkdir(parents=True)
                result = run("python3", "bin/tmux-project", "--print", str(project))
                target = json.loads(result.stdout)
                self.assertEqual(target["directory"], str(project.resolve()))
                self.assertNotIn(" ", target["session"])
                names.append(target["session"])
            self.assertNotEqual(*names)

    def test_task_arguments_root_and_failure_status(self):
        with tempfile.TemporaryDirectory(prefix="dotfiles-task-") as directory:
            project = Path(directory)
            child = project / "child"
            child.mkdir()
            (project / ".dotfiles-tasks.json").write_text(json.dumps({
                "show": ["python3", "-c", "import os,sys; print(os.getcwd()); print(sys.argv[1])"],
                "fail": ["python3", "-c", "import sys; print('file.py:2: error: example'); sys.exit(7)"],
            }))
            result = run("python3", str(ROOT / "bin/project-task"), "show", "--", "space here; literal",
                         cwd=child)
            self.assertEqual(result.stdout.splitlines(), [str(project.resolve()), "space here; literal"])
            log = project / "result.log"
            result = run("python3", str(ROOT / "bin/project-task"), "--log", str(log), "fail",
                         cwd=child, check=False)
            self.assertEqual(result.returncode, 7)
            self.assertEqual(log.read_text(), result.stdout)

    def test_iterm_profile_is_additive_and_uses_canonical_themes(self):
        profile = json.loads(run("python3", "bin/dotfiles-iterm").stdout)["Profiles"][0]
        self.assertEqual(profile["Name"], "Dotfiles")
        self.assertEqual(profile["Scrollback Lines"], 50000)
        self.assertEqual(profile["Right Option Key Sends"], 0)
        self.assertEqual(profile["Option Key Sends"], 2)
        self.assertEqual(round(profile["Background Color (Dark)"]["Red Component"] * 255), 30)


@unittest.skipUnless(shutil.which("tmux"), "tmux is not installed")
class TmuxTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="dotfiles-tmux-")
        self.socket = str(Path(self.temp.name) / "socket")
        self.tmux("-f", "/dev/null", "new-session", "-d", "-x", "189", "-y", "47",
                  "-s", "audit", "sleep 120")

    def tearDown(self):
        self.tmux("kill-server", check=False)
        self.temp.cleanup()

    def tmux(self, *args, **kwargs):
        return run("tmux", "-S", self.socket, *args, **kwargs)

    def test_fresh_configuration_and_reload_without_plugins(self):
        config = (ROOT / "link/.tmux.conf").read_text()
        config = config.split("# Initialize TMUX plugin manager")[0]
        # Exercise the real missing-plugin branch, never touching installed plugins.
        config = config.replace('$HOME/.tmux/plugins/', self.temp.name + "/missing/")
        config = config.replace("~/.tmux/resize-restored-windows.sh",
                                str(ROOT / "link/.tmux/resize-restored-windows.sh"))
        for _ in range(3):
            result = self.tmux("source-file", "-", input=config)
            self.assertNotIn("No such file", result.stdout + result.stderr)
        environment = self.tmux("show-options", "-g", "update-environment").stdout
        self.assertEqual(environment.count("COLORFGBG"), 1)
        self.assertEqual(self.tmux("show-options", "-gqv", "status-interval").stdout.strip(), "15")

    def test_installed_theme_modules_and_resource_colors(self):
        candidates = [
            ROOT / "link/.tmux/plugins/tmux/catppuccin.tmux",
            Path.home() / ".tmux/plugins/tmux/catppuccin.tmux",
        ]
        theme = next((path for path in candidates if path.is_file()), None)
        if theme is None:
            self.skipTest("Catppuccin tmux theme is not installed")
        config = (ROOT / "link/.tmux.conf").read_text().split("# Initialize TMUX plugin manager")[0]
        config = config.replace('$HOME/.tmux/plugins/', str(theme.parent.parent) + "/")
        config = config.replace('$HOME/.tmux/custom_modules', str(ROOT / "link/.tmux/custom_modules"))
        result = self.tmux("source-file", "-", input=config)
        self.assertNotIn("No such file", result.stdout + result.stderr)
        self.assertTrue(self.tmux("show-options", "-gqv", "@catppuccin_status_memory").stdout.strip())
        colors = []
        for reading in ["20.0%", "50.0%", "90.0%"]:
            self.tmux("set-environment", "-g", "ram_percentage", reading)
            colors.append(self.tmux("display-message", "-p", "#{E:@catppuccin_memory_color}").stdout.strip())
        self.assertEqual(len(set(colors)), 3)
        self.assertNotIn("ram_bg_color", self.tmux("show-options", "-gqv", "status-right").stdout)

    def test_restored_layout_fills_window_without_losing_panes(self):
        for pane_count in [1, 2]:
            self.tmux("resize-window", "-x", "117", "-y", "43")
            if pane_count == 2:
                self.tmux("split-window", "-h", "sleep 120")
            old_layout = self.tmux("display-message", "-p", "#{window_layout}").stdout.strip()
            self.tmux("resize-window", "-x", "189", "-y", "47",
                      ";", "select-layout", old_layout, ";", "set-option", "-wu", "window-size")
            script = ROOT / "link/.tmux/resize-restored-windows.sh"
            self.tmux("run-shell", f"'{script}'; tmux wait-for -S repaired")
            self.tmux("wait-for", "repaired")
            current = self.tmux("display-message", "-p", "#{window_layout}").stdout
            self.assertIn(",189x47,", current)
            self.assertEqual(len(self.tmux("list-panes").stdout.splitlines()), pane_count)
            self.assertEqual(self.tmux("show-options", "-wqv", "window-size").stdout, "")

    def test_navigation_through_an_attached_client(self):
        candidates = [
            ROOT / "link/.tmux/plugins/vim-tmux-navigator/vim-tmux-navigator.tmux",
            Path.home() / ".local/share/nvim/lazy/vim-tmux-navigator/vim-tmux-navigator.tmux",
        ]
        plugin = next((path for path in candidates if path.is_file()), None)
        if plugin is None:
            self.skipTest("navigator plugin is not installed")
        self.tmux("run-shell", f"bash '{plugin}'; tmux wait-for -S navigation-ready")
        self.tmux("wait-for", "navigation-ready")
        self.tmux("split-window", "-h", "sleep 120")
        panes = self.tmux("list-panes", "-F", "#{pane_id}").stdout.splitlines()
        master, slave = pty.openpty()
        client = subprocess.Popen(["tmux", "-S", self.socket, "attach-session", "-t", "audit"],
                                  stdin=slave, stdout=slave, stderr=slave,
                                  env={**os.environ, "TERM": "xterm-256color"})
        os.close(slave)
        try:
            for _ in range(30):
                if self.tmux("list-clients").stdout:
                    break
                time.sleep(0.05)
            for key, expected in [(b"\x08", panes[0]), (b"\x0c", panes[1])]:
                os.write(master, key)
                for _ in range(30):
                    current = self.tmux("display-message", "-p", "#{pane_id}").stdout.strip()
                    if current == expected:
                        break
                    time.sleep(0.05)
                self.assertEqual(current, expected)
            clear_binding = self.tmux("list-keys", "-T", "prefix").stdout
            self.assertIn("send-keys C-l", clear_binding)
        finally:
            client.terminate()
            client.wait(timeout=5)
            os.close(master)


@unittest.skipUnless(shutil.which("nvim"), "Neovim is not installed")
class EditorTests(unittest.TestCase):
    def test_sign_is_visible_and_inline_hints_disabled(self):
        lua = """
dofile('config/nvim/lua/config/options.lua')
vim.o.signcolumn='yes'
vim.fn.setline(1, {'one','two'})
vim.fn.sign_define('AuditSign', {text='E', texthl='ErrorMsg'})
vim.fn.sign_place(9001,'audit','AuditSign',vim.api.nvim_get_current_buf(),{lnum=1})
vim.cmd('redraw')
assert(vim.api.nvim_eval_statusline(vim.o.statuscolumn,{use_statuscol_lnum=1}).str:find('E'))
local spec=dofile('config/nvim/lua/plugins/lang.lua')
assert(spec[2].opts.inlay_hints.enabled==false)
assert(spec[2].opts.diagnostics.virtual_text==false)
print('EDITOR_TEST_OK')
"""
        result = run("nvim", "--headless", "-u", "NONE", "-i", "NONE", "-c", "lua " + lua, "-c", "qa!")
        self.assertIn("EDITOR_TEST_OK", result.stdout + result.stderr)
        self.assertNotIn("Error", result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
