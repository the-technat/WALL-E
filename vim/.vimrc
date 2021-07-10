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

"------ Styling Plugins ------
" https://github.com/altercation/vim-colors-solarized
Plug 'altercation/vim-colors-solarized'
" https://github.com/itchyny/lightline.vim
Plug 'itchyny/lightline.vim'
" https://github.com/airblade/vim-gitgutter
Plug 'airblade/vim-gitgutter'

"------ Editor Plugins ------
" https://github.com/preservim/nerdtree
Plug 'preservim/nerdtree'
" https://github.com/tpope/vim-commentary
Plug 'tpope/vim-commentary'
" https://github.com/editorconfig/editorconfig-vim#readme
Plug 'editorconfig/editorconfig-vim'
" https://github.com/christoomey/vim-system-copy
Plug 'christoomey/vim-system-copy'

"------ IDE Plugins ------
" https://github.com/neoclide/coc.nvim
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" https://github.com/dense-analysis/ale
Plug 'dense-analysis/ale'

"------ Language Support Plugins ------
" https://github.com/fatih/vim-go
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
" https://github.com/hashivim/vim-terraform
Plug 'hashivim/vim-terraform'
" https://github.com/martinda/Jenkinsfile-vim-syntax
Plug 'martinda/Jenkinsfile-vim-syntax'
" https://github.com/stephpy/vim-php-cs-fixer
Plug 'stephpy/vim-php-cs-fixer'
" https://github.com/mattn/emmet-vim
Plug 'mattn/emmet-vim'

"------ last plugin ------
" https://github.com/ryanoasis/vim-devicons
Plug 'ryanoasis/vim-devicons'

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

" nerdtree
" Start NERDTree when Vim starts with a directory argument.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in') |
    \ execute 'NERDTree' argv()[0] | wincmd p | enew | execute 'cd '.argv()[0] | endif

" ale
" Set this variable to 1 to fix files when you save them.
let g:ale_fix_on_save = 1

" lightline
let g:lightline = {'colorscheme': 'solarized',}

""""""""""""""""""""""""""""""""
" Keybindings
""""""""""""""""""""""""""""""""
" Awesome: https://alldrops.info/posts/vim-drops/2018-05-15_understand-vim-mappings-and-create-your-own-shortcuts/
" With a map leader it's possible to do extra key combinations
let mapleader = ","

" source vimrc
noremap <silent> <leader>r :source ~/.vimrc<cr>

" ------ Files ------
" Fast saving
noremap <nowait> <leader>w :w!<cr>
" :W sudo saves the file(useful for handling the permission-denied error)
command! W execute 'w !sudo tee % > /dev/null' <bar> edit!
" Toggle paste mode on and off
noremap <leader>pp :setlocal paste!<cr>

" ------ Editor ------
" clear search results
noremap ,<space> :nohlsearch<CR>
 
" ------ Nerdtree ------
" Open Nerdtree
noremap <silent> <leader>o :NERDTreeToggle<CR>

" ------ Tabs ------
" new tab
noremap <silent> <leader>t :tabnew<cr>
" Go to tab by number
noremap <leader>1 1gt
noremap <leader>2 2gt
noremap <leader>3 3gt
noremap <leader>4 4gt
noremap <leader>5 5gt
noremap <leader>6 6gt
noremap <leader>7 7gt
noremap <leader>8 8gt
noremap <leader>9 9gt
noremap <leader>0 :tablast<cr>
 " Go to last active tab
au TabLeave * let g:lasttab = tabpagenr()
noremap <silent> <leader>l :exe "tabn ".g:lasttab<cr>
noremap <silent> <leader>l :exe "tabn ".g:lasttab<cr>

" ------ Windows ------
" Window splitting
noremap <silent> <leader>wl :leftabove vnew<cr>
noremap <silent> <leader>wr :rightbelow vnew<cr>
noremap <silent> <leader>wa :leftabove new<cr>
noremap <silent> <leader>wb :rightbelow new<cr>
" noremap <silent> <leader>swh :topleft vnew<cr>
" noremap <silent> <leader>swl :botright vnew<cr>
" noremap <silent> <leader>swk :topleft new<cr>
" noremap <silent> <leader>swj :botright new<cr>
" moving around between windows
noremap <silent> <C-j> <C-W>j
noremap <silent> <C-k> <C-W>k
noremap <silent> <C-h> <C-W>h
noremap <silent> <C-l> <C-W>l

" Scroll the window next to the current one
" (especially useful for two-window splits)
noremap <silent> <leader>wj <c-w>w<c-d><c-w>W
noremap <silent> <leader>wk <c-w>w<c-u><c-w>W

" Move a line of text using ALT+[jk] 
" not working right now
vnoremap <leader>k :m'>+<cr>`<my`>mzgv`yo`z
nnoremap <leader>k mz:m-2<cr>`z
vnoremap <leader>j :m'<-2<cr>`>my`<mzgv`yo`z
nnoremap <leader>j mz:m+<cr>`z

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
