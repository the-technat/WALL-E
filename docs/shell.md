# Shell Environment

For an Engineer the shell environment is probably the most important environment as it's his workplace, his workspace and can be customized however he wants.

Often times GUI and Shell environments mix with each other and it's not very clear what is done in a GUI and where GUIs respect the shell.

So this Guide shows how I configured my Shell environment on Arch using [sway](https://swaywm.org/) as a wayland compositor.

## Terminal Emulator

When you use a graphical environment you don't have the TTY directly, so you need some sort of a terminal emulator to work with. The [sway-de](./sway-de.md) guide already installed [kitty](https://sw.kovidgoyal.net/kitty/) as my prefered and configured terminal emulator. 

I launch it using Space+Enter. The cool thing about it is that you can customize and configure it to your likings, so I got my own config file:

```bash
cd ~/WALL-E
stow kitty
```

## Shell 

A Terminal Emulator launches a shell by default. My prefered one is ZSH using the [oh-my-zsh](https://ohmyz.sh/) framework to configure it.


```bash
sudo pacman -S zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
rm ~/.zshrc
cd ~/WALL-E
stow zsh
```

Note: You must enter your password to change the shell of your user.
  
## tmux (Orphaned)

Prior to kitty I used tmux to have multiple virtual terminals. Now with kitty you can do this at it's own.

I still have a `tmux.conf` file with some usefull customizations I prefer. If needed:

```bash
sudo pacman -S tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
cd ~/WALL-E
stow tmux
tmux # prefix + I to install plugins
```  

Note: You need to adjust the terminal colors of your terminal emulator to match solarized theme. Otherwise the colors look bad because tmux has a solarized dark color scheme set.

### Languages

On a terminal you need programm languages. So here I list out some that I need for further tooling and working and how to tweak them.

Go:

```bash
sudo pacman -S go
export GOROOT="/usr/lib/go"
export GOPATH="/home/technat/go"
export GOBIN=$GOPATH/"bin"
export PATH=$PATH:$GOBIN
```

Python:

```bash
sudo pacman -S python python-pip
```

NodeJS:

```bash
sudo pacman -S nodejs npm
```

Terraform:

```bash
sudo pacman -S terraform 
yay -As terraform-docs terraform-lsp
```

YAML:

```bash
sudo pacman -S yamllint yq
```

JSON:

```bash
sudo pacman -S jq
```

### vim

Now comes my editor. I use it to edit many files including the programming languages I installed above.

There are a bunch of plugins set in my `.vimrc` file. All the required tools should already by installed in the languages section, so we can simply link the .vimrc file and it will install all the plugins automatically:

```bash
cd ~/WALL-E
stow vim
```

Unfortunatelly there is currently no way to install coc languageservers using the vimrc, so do this manually:

```bash
vim +CocInstall coc-go 
```

Btw for plugins to be used we need [vim-plug](https://github.com/junegunn/vim-plug). It will install itself when starting vim for the first time as well as installing all the plugins.

## Ranger

[Ranger](https://github.com/ranger/ranger) is a terminal file manager written in Python. It has a config file in `~/.config/ranger/rc.conf` which can be stowed.

```bash
sudo pacman -S ranger
stow ranger
```
