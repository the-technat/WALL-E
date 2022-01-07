# Shell Environment

For an Engineer the shell environment is probably the most important environment as it's his workplace, his workspace and can be customized however he wants.
Often times GUI and Shell environments mix with each other and it's not very clear what is done in a GUI and where GUIs respect the shell.

My shell of choice is ZSH using the [oh-my-zsh](https://ohmyz.sh/) framework.

```bash
sudo pacman -S zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
rm ~/.zshrc
cd ~/WALL-E
stow zsh
```

Note: You must enter your password to change the shell of your user.

## tmux

Sometimes it's useful to have a terminal multiplexer. Although you could also spawn a new terminal window. I have a `tmux.conf` file with some usefull customizations I prefer. So let's set this up.
With a tiling window manager like swaywm it's not really necessary to use tmux but let's set it up:

```bash
sudo pacman -S tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
cd ~/WALL-E
stow tmux
tmux # prefix + I to install plugins
```  

Note: You need to adjust the terminal colors of your terminal emulator to match solarized theme. Otherwise the colors look bad because tmux has a solarized dark color scheme set.

## Ranger

[Ranger](https://github.com/ranger/ranger) is a terminal file manager written in Python. It has a config file in `~/.config/ranger/rc.conf` which can be stowed.

```bash
sudo pacman -S ranger
stow ranger
```

## SSH / GPG Key management

According to [this blog post](https://www.dzombak.com/blog/2021/02/Securing-my-personal-SSH-infrastructure-with-Yubikeys.html) my new ssh situation will look like that:

