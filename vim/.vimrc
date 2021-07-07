" .vimrc of Technat (https://technat.ch)
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
" vim-plug
""""""""""""""""""""""""""""""""
" install if not present
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
            \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall | source ~/.vimrc 
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs),'!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

""""""""""""""""""""""""""""""""
" Plugins (vim-plug)
""""""""""""""""""""""""""""""""
" start plugin list, define directory
call plug#begin('~/.vim/plugged')

" vim-colors-solarized
" https://github.com/altercation/vim-colors-solarized
Plug 'altercation/vim-colors-solarized'

" lightline
" https://github.com/itchyny/lightline.vim
Plug 'itchyny/lightline.vim'

" go-vim
" https://github.com/fatih/vim-go
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" coc
" https://github.com/neoclide/coc.nvim
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" vim-terraform
" https://github.com/hashivim/vim-terraform
Plug 'hashivim/vim-terraform'

" vim-commentary
" https://github.com/tpope/vim-commentary
Plug 'tpope/vim-commentary'

" editorconfig-vim
" https://github.com/editorconfig/editorconfig-vim#readme
Plug 'editorconfig/editorconfig-vim'

" vim-system-copy
" https://github.com/christoomey/vim-system-copy
Plug 'christoomey/vim-system-copy'

" Jenkinsfile-vim-syntax
" https://github.com/martinda/Jenkinsfile-vim-syntax
Plug 'martinda/Jenkinsfile-vim-syntax'

" vim-php-cs-fixer
" https://github.com/stephpy/vim-php-cs-fixer
Plug 'stephpy/vim-php-cs-fixer'

" Initialize plugin system
call plug#end()


""""""""""""""""""""""""""""""""
" coc language servers
""""""""""""""""""""""""""""""""
" https://github.com/josa42/coc-go
" CocInstall coc-go
" CocInstall coc-phpls

""""""""""""""""""""""""""""""""
" Plugin Configs
""""""""""""""""""""""""""""""""
" vim-terraform
let g:terraform_align=1 " align equal sings when saving
let g:terraform_fmt_on_save=1 " run fmt when saving

" coc
let g:coc_disable_startup_warning  = 1

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

set background=dark " or light
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

" 1 tab == 2 spaces
set shiftwidth=2
set tabstop=2

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines

