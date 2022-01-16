" .vimrc of Technat (https://technat.ch)
""""""""""""""""""""""""""""""""
" vim-plug
""""""""""""""""""""""""""""""""
" install vim-plug if not present
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
            \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall | source ~/.vimrc
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs),'!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source ~/.vimrc
\| endif

""""""""""""""""""""""""""""""""
" Plugins (vim-plug)
""""""""""""""""""""""""""""""""
" start plugin list, define directory
call plug#begin('~/.vim/plugged')

"------ Styling Plugins ------
" https://github.com/altercation/vim-colors-solarized
Plug 'altercation/vim-colors-solarized'
" https://github.com/vim-airline/vim-airline
Plug 'vim-airline/vim-airline'
" https://github.com/vim-airline/vim-airline-themes#vim-airline-themes--
Plug 'vim-airline/vim-airline-themes'
" https://github.com/airblade/vim-gitgutter
Plug 'airblade/vim-gitgutter'
" https://github.com/Yggdroot/indentLine
Plug 'Yggdroot/indentLine'

"------ Editor Features------
" https://github.com/jreybert/vimagit
Plug 'jreybert/vimagit'
" https://github.com/tpope/vim-commentary
Plug 'tpope/vim-commentary'
" https://github.com/editorconfig/editorconfig-vim
Plug 'editorconfig/editorconfig-vim'
" https://github.com/mattn/emmet-vim
Plug 'mattn/emmet-vim'

" Initialize plugin system
call plug#end()

""""""""""""""""""""""""""""""""
" Plugin Configs
""""""""""""""""""""""""""""""""

" airline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline#extensions#tabline#formatter = 'default'
let g:airline_theme='solarized'

""""""""""""""""""""""""""""""""
" General
""""""""""""""""""""""""""""""""
" Disable compatibility with vi which can cause unexpected issues.
set nocompatible

" show line numbers
set number

" detect the filetype and load additional scripts automatically
filetype on
filetype plugin on
filetype indent on

" Set vims updatetime to 100ms
set updatetime=100

" Enable auto completion menu after pressing TAB.
set wildmenu

" Make wildmenu behave like similar to Bash completion.
set wildmode=list:longest

" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" There are certain files that we would never want to edit with Vim.
" Wildmenu will ignore files with these extensions.
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

" Set to auto read when a file is changed from the outside
set autoread

" trigger autoread when vim get's focus or when buffer is switched
au FocusGained,BufEnter * checktime

" also save files when focus is lost of buffer is left
au FocusLost,WinLeave * :silent! w

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
" Texting (e.g tabs, spaces and more encoding)
""""""""""""""""""""""""""""""""
" Set utf8 as standard encoding
set encoding=utf8

" Use Unix as the standard file type
set ffs=unix,dos,mac

" Use spaces instead of tabs
set expandtab

" Be smart when using tabs ;)
set smarttab

" Set shift width to 2 spaces
set shiftwidth=2

" Set tab width to 2 colums
set tabstop=2

" You can also define tabstop,shiftwidth per file ending
" autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines


""""""""""""""""""""""""""""""""
" Look and feel
""""""""""""""""""""""""""""""""
" Enable syntax highlighting
syntax enable

" Highlight cursor line underneath the cursor horizontally.
set cursorline

" fix lightline not showing statusline
set laststatus=2

"remove current mode status bar at bottom
set noshowmode

" configure colorscheme
set background=dark " or dark
colorscheme solarized

""""""""""""""""""""""""""""""""
" Keybindings
""""""""""""""""""""""""""""""""
" Awesome article: https://alldrops.info/posts/vim-drops/2018-05-15_understand-vim-mappings-and-create-your-own-shortcuts/
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
" Move a line of text using <leader>+[jk]
vnoremap <leader>k :m'>+<cr>`<my`>mzgv`yo`z
nnoremap <leader>k mz:m-2<cr>`z
vnoremap <leader>j :m'<-2<cr>`>my`<mzgv`yo`z
nnoremap <leader>j mz:m+<cr>`z

" Jump to the next linting error
nmap <silent> <leader>e <Plug>(ale_next_wrap)

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
noremap <silent> <leader>wh :leftabove vnew<cr>
noremap <silent> <leader>wl :rightbelow vnew<cr>
noremap <silent> <leader>wk :leftabove new<cr>
noremap <silent> <leader>wj :rightbelow new<cr>
" noremap <silent> <leader>swh :topleft vnew<cr>
" noremap <silent> <leader>swl :botright vnew<cr>
" noremap <silent> <leader>swk :topleft new<cr>
" noremap <silent> <leader>swj :botright new<cr>
" moving around between windows
noremap <silent> <C-j> <C-W>j
noremap <silent> <C-k> <C-W>k
noremap <silent> <C-l> <C-W>l
noremap <silent> <C-h> <C-W>h
" Scroll the window next to the current one
" (especially useful for two-window splits)
noremap <silent> <leader>jj <c-w>w<c-d><c-w>W
noremap <silent> <leader>kk <c-w>w<c-u><c-w>W

