# My Dotfiles

## My main configuration files:

- fonts in .fonts are mostly fonts for [powerline](https://github.com/powerline/fonts) support
- konsole contains my konsole themes and profile (lives in `$HOME/.local/share/konsole`)
- icons contains [papirus](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme) icons edited to match gruvbox style _(see my topbar screenshot)_
- inside .bash there is `blerc` and `ble.sh` to configure [ble.sh](https://github.com/akinomyoga/ble.sh) **NOTE** You need to run make inside `.bash/ble.sh` (gawk is needed for this)
  - there is also [fzf-bindings.sh](https://github.com/junegunn/fzf/blob/master/shell/key-bindings.bash) for fzf bindings and [fzf-marks-plugin.sh](https://github.com/urbainvaes/fzf-marks) for directory marks with fzf
- .gdbinit was downloaded from [gdb-dashboard](https://github.com/cyrus-and/gdb-dashboard)


## .config files (Mainly files for [bspwm](https://github.com/baskerville/bspwm) + [sxhkd](https://github.com/baskerville/sxhkd) + [polybar](https://github.com/jaagr/polybar) + [Compton](https://github.com/chjj/compton))
- rofi directory used for [rofi](https://github.com/DaveDavenport/rofi) - see my custom [rofi launch script for Plasma](.bash/scripts/rofi-blurred)
- zathura directory with gruvbox colorstyle for zathura copied from [abdullaev](https://github.com/abdullaev/dotfiles/blob/master/.config/zathura/zathurarc)
- Code contains my _user settings_, _keyboard shortcuts_ and a _list of installed extensions_

Most of my files are set with the [gruvbox](https://github.com/morhetz/gruvbox) colorscheme.

## Installation and Cloning

This repository contains submodules for the vim extensions, therefore you have to clone the submodules for vim to work correctly. Do either:

`git clone --recurse-submodules -j8 [this-repo-url]`

where -j8 is the number of jobs to run in paralell. Or:

```
git clone [this-repo-url]
git submodule init
git submodule update
```

To update the vim plugins and the repo use

```
git pull --recurse-submodules
```

If new submodules where added you might need to run `git submodule init` again

A script is provided to link the files. Run `install_my_config.sh --help` for its usage.

## Dependencies

 - `gawk` for building ble.sh
 - `fzf` for some keybindings and bookmark directories in bash
 - `delta` for generating git diffs (setup in `.gitconfig`) [delta](https://github.com/dandavison/delta#used-by-delta)

## Prompts

### Prompt 7

![77](screenshots/7_normal.png)
![77f](screenshots/7_full.png)

Other prompts are available and can be set with the function `prompt [1-7]`

Prompts support:

- git directories and status of the files (untracked, staged... aswell as upstream checks), but you must source `.bash/git-prompt.sh`
- diferent colors for normal user / root / ssh session user (in **prompt 6, 7** this segment is hidden unless the user is root or in an ssh session)
- python virtual environments. **except prompt 1**
- last command exit status ( failed or succeded )
z,s
- compress some paths ( my repository path is compressed into "R:" . **except prompt 5, 6, 7**
- background jobs counter
- command counter **only prompt 5, 6, 7**
- show the respective tty. **except 6, 7**
- display virtual machine environment indicator **only prompt 7**

## Vim plugins (using [Vundle](https://github.com/VundleVim/Vundle.vim))

 -  [vim-airline](https://github.com/vim-airline/vim-airline)
 -  [nerdtree](https://github.com/scrooloose/nerdtree)
 -  [nerdtree-git-plugin](https://github.com/Xuyuanp/nerdtree-git-plugin)

### Git
 -  [vim-gitgutter](https://github.com/airblade/vim-gitgutter)
 -  [vim-fugitive](https://github.com/tpope/vim-fugitive)
 -  [vim-rhubarb](https://github.com/tpope/vim-rhubarb)

### Tools
 -  [vim-surround](https://github.com/tpope/vim-surround)
 -  [vim-commentary](https://github.com/tpope/vim-commentary)
 -  [gundo.vim](https://github.com/sjl/gundo.vim)
 -  [vim-easymotion](https://github.com/easymotion/vim-easymotion)
 -  [clever-f.vim](https://github.com/rhysd/clever-f.vim)
 -  [linediff.vim](https://github.com/AndrewRadev/linediff.vim)
 -  [vim-peekaboo](https://github.com/junegunn/vim-peekaboo)
 -  [ctrlp.vim](https://github.com/ctrlpvim/ctrlp.vim)
 -  [vim-markology](https://github.com/jeetsukumaran/vim-markology)
 -  [vim-markbar](https://github.com/Yilin-Yang/vim-markbar)

### Tmux integration
 -  [vim-tmux-focus-events](https://github.com/tmux-plugins/vim-tmux-focus-events)
 -  [vim-tmux-clipboard](https://github.com/roxma/vim-tmux-clipboard)

### Syntax highlight
 -  [vim-syntax-extra](https://github.com/justinmk/vim-syntax-extra)
 -  [vim-ps1](https://github.com/PProvost/vim-ps1)
 -  [python-syntax](https://github.com/vim-python/python-syntax)

### Colors
 -  [gruvbox](https://github.com/morhetz/gruvbox)

### Others
 -  [vim-startify](https://github.com/mhinz/vim-startify)
 -  [vim-numbertoggle](https://github.com/jeffkreeftmeijer/vim-numbertoggle)
 -  [vim-auto-origami](https://github.com/benknoble/vim-auto-origami)
 -  [vim-anzu](https://github.com/osyo-manga/vim-anzu)

## Vim (gruvbox theme) screenshots

![7](screenshots/vim.png)

## Tmux
![12](screenshots/tmux2.png)

Tmux has a lot of custom configurations added in `.tmux.conf` and a few plugins added as submodules that are managed through [TPM (Tmux Plugin Manager)](https://github.com/tmux-plugins/tpm)

 - [tmux-prefix-highlight](https://github.com/tmux-plugins/tmux-prefix-highlight)
 - [tmux-copycat](https://github.com/tmux-plugins/tmux-copycat)
 - [tmux-battery](https://github.com/tmux-plugins/tmux-battery)
 - [tmux-plugin-uptime](https://github.com/3ximus/tmux-plugin-uptime)
 - [tmux-plugin-datetime](https://github.com/3ximus/tmux-plugin-datetime)

### My other themes to go along with the gruvbox colorscheme
 - [GTK](https://github.com/3ximus/gruvbox-gtk)
 - [Plasma](https://github.com/3ximus/gruvbox-plasma)
 - [VS Code](https://github.com/jdinhlife/vscode-theme-gruvbox)

## More Screenshots

![10](screenshots/complete1.png)
vim, htop and ranger (all in tmux sessions)

![12](screenshots/rofi.png)
rofi (launched with [.bash/scripts/rofi-blurred.sh](.bash/scripts/rofi-blurred.sh))

![13](screenshots/topbar.png)
plasma top bar

