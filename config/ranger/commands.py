import os
import shutil
import subprocess
from ranger.api.commands import Command


class fzf_select(Command):
    """Jump to a file/dir using fzf."""

    def execute(self):
        fd = shutil.which("fd") or shutil.which("fdfind")
        # A dedicated override preserves both files and directories even when
        # the shell's default picker only searches files.
        fzf_cmd = os.environ.get("RANGER_FZF_COMMAND")
        if not fzf_cmd and fd:
            import shlex
            fzf_cmd = shlex.quote(fd) + " --hidden --exclude .git --type f --type d"
        env = os.environ.copy()
        if fzf_cmd:
            env["FZF_DEFAULT_COMMAND"] = fzf_cmd
        else:
            env.pop("FZF_DEFAULT_COMMAND", None)  # use fzf's built-in walker
        preview = "fzf-tab-preview {}"
        fzf = self.fm.execute_command(
            f"fzf --height 40% --reverse --preview '{preview}'",
            universal_newlines=True,
            stdout=subprocess.PIPE,
            env=env,
        )
        stdout, _ = fzf.communicate()
        if fzf.returncode == 0:
            path = os.path.abspath(stdout.rstrip("\n"))
            if os.path.isdir(path):
                self.fm.cd(path)
            else:
                self.fm.select_file(path)
