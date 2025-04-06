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
~/.dotfiles/bin/dotfiles
source ~/.zshrc
```

To update the dotfiles:
```sh
dotfiles
```

# Other Dotfiles repots to look at:
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
