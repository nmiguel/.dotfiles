Just a place for my dotfiles


# Installation

This repository uses GNU Stow to install. Use the following command

`stow . -t $HOME`

Some configurations may not go to correct folder.
This is the case, for example, with Wezterm, which is needed in the host OS.
For such cases, a symlink may be used, unless the dotfiles OS differs from the target OS, where it is actually needed to clone the submodule.

Use `ln [TARGET] [SOURCE] -s` to create a symlink.
