import os
import subprocess
from ranger.api.commands import Command


class fzf_select(Command):
    """Jump to a file/dir using fzf."""

    def execute(self):
        fzf_cmd = os.environ.get(
            "FZF_DEFAULT_COMMAND",
            "fd --type f --hidden --follow --exclude .git",
        )
        preview = "fzf-tab-preview {}"
        fzf = self.fm.execute_command(
            f"fzf --height 40% --reverse --preview '{preview}'",
            universal_newlines=True,
            stdout=subprocess.PIPE,
        )
        stdout, _ = fzf.communicate()
        if fzf.returncode == 0:
            path = os.path.abspath(stdout.rstrip("\n"))
            if os.path.isdir(path):
                self.fm.cd(path)
            else:
                self.fm.select_file(path)
