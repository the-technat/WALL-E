" .vimrc of Technat (Server-Edition, https://technat.ch)
" credits to https://github.com/amix/vimrc (used as inspiration)

""""""""""""""""""""""""""""""""
" General
""""""""""""""""""""""""""""""""
set number " show line numbers

" detect the filetype and set the option
" https://vi.stackexchange.com/questions/10124/what-is-the-difference-between-filetype-plugin-indent-on-and-filetype-indent
filetype on
filetype plugin on
filetype indent on

" Set to auto read when a file is changed from the outside
set autoread
" trigger autoread when vim get's focus or when buffer is switched
" https://stackoverflow.com/questions/2490227/how-does-vims-autoread-work
au FocusGained,BufEnter * checktime
" also save files when focus is lost of buffer is left
au FocusLost,WinLeave * :silent! w

" Set utf8 as standard encoding
set encoding=utf8

" Use Unix as the standard file type
set ffs=unix,dos,mac

""""""""""""""""""""""""""""""""
" Plugins (vim-plug)
""""""""""""""""""""""""""""""""
" install vim-plug if not present
" https://devel.tech/snippets/n/vIMmz8vZ/minimal-vim-configuration-with-vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
            \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
      autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

" start plugin list, define directory
call plug#begin('~/.vim/plugged')

" vim-colors-solarized
" https://github.com/altercation/vim-colors-solarized
Plug 'altercation/vim-colors-solarized'

" lightline
" https://github.com/itchyny/lightline.vim
Plug 'itchyny/lightline.vim'

" vim-commentary
" https://github.com/tpope/vim-commentary
Plug 'tpope/vim-commentary'

" Initialize plugin system
call plug#end()

""""""""""""""""""""""""""""""""
" Keybindings
""""""""""""""""""""""""""""""""
" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let mapleader = ","

" Fast saving
nmap <leader>w :w!<cr>

" :W sudo saves the file 
" (useful for handling the permission-denied error)
command! W execute 'w !sudo tee % > /dev/null' <bar> edit!

" Toggle paste mode on and off
map <leader>pp :setlocal paste!<cr>

" Move a line of text using ALT+[jk] or Command+[jk] on mac
" not working right now
" nmap <M-j> mz:m+<cr>`z
" nmap <M-k> mz:m-2<cr>`z
" vmap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
" vmap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z

""""""""""""""""""""""""""""""""
" VIM user interface
""""""""""""""""""""""""""""""""
" Ignore case when searching
set ignorecase

" When searching try to be smart about cases 
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch 

" Return to last edit position when opening files (You want this!)
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif


""""""""""""""""""""""""""""""""
" Look and feel
""""""""""""""""""""""""""""""""
" Enable syntax highlighting
syntax enable 

set laststatus=2 " fix lightline not showing statusline
set noshowmode "remove current mode status bar at bottom

set background=light " or dark
colorscheme solarized

" lightline theme
let g:lightline = {'colorscheme': 'solarized',}

""""""""""""""""""""""""""""""""
" Tabs and spaces
""""""""""""""""""""""""""""""""
" Use spaces instead of tabs
set expandtab

" Be smart when using tabs ;)
set smarttab

" 1 tab == 24spaces
set shiftwidth=4
set tabstop=4

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines

