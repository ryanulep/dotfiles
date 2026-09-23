# Ubuntu specific configuration
is_ubuntu || return 1

sudo apt update;
cat $DOTFILES/conf/packages/apt | xargs sudo apt install --assume-yes;