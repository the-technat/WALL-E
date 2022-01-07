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

## File Manager

I use nnn as my file manager as it can handle image previews and much more while beeing fast.

Install it and dependencies:

```bash
sudo pacman -S nnn
yay -aS bat viu ffmpegthumbnailer file pdftoppm fontpreview glow sxiv tabbed xdotool jq trash-cli vidir
```

But just installing nnn is not enough, it needs to be configured. This is done using some environment variables. If you have stowed my zsh config the vars are already set.

Otherwise export them somewhere in an rc file:

```bash
cat ~/WALL-E/zsh/.zshenv | grep "nnn Vars" -A 20
```

nnn itself is not very spectacular. What makes it really interesting are the plugins you can use. So for my config I use the plugins. You can find them [here](https://github.com/jarun/nnn/tree/master/plugins) and in this directory you will also find a neat one-liner to download them:

```bash
curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs | sh
```

Now you can find the plugins in `~/.config/nnn/plugins`. Start using them by exporting the `NNN_PLUG` variable.

While setting up my own nnn config I realized that most of the nnn plugins are just helpers to integrate with other programms out there. That's why you end up installing some more tools to work perfectly with nnn.

### Plugins

- `p:preview-tui` - File preview in terminal or tmux pane, very basic
- `t:preview-tabbed` - File preview with correct programm - usefull for image sorting

[Source](https://github.com/jarun/nnn)

## SSH / GPG Key management

According to [this blog post](https://www.dzombak.com/blog/2021/02/Securing-my-personal-SSH-infrastructure-with-Yubikeys.html) my new ssh situation will look like that:

on my laptop there is one key which is allowed to login everywhere in technat_cloud

Install the agent: [guide](https://github.com/FiloSottile/yubikey-agent#arch)
