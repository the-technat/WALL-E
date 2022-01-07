" .vimrc of Technat (https://technat.ch)
" credits to https://github.com/amix/vimrc (used as inspiration)

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
" https://github.com/itchyny/lightline.vim
Plug 'itchyny/lightline.vim'
" https://github.com/airblade/vim-gitgutter
Plug 'airblade/vim-gitgutter'

"------ Editor Plugins ------
" https://github.com/tpope/vim-commentary
Plug 'tpope/vim-commentary'
" https://github.com/editorconfig/editorconfig-vim#readme
Plug 'editorconfig/editorconfig-vim'
" https://github.com/christoomey/vim-system-copy
Plug 'christoomey/vim-system-copy'

"------ IDE Plugins ------
" https://github.com/dense-analysis/ale
Plug 'dense-analysis/ale'

"------ Language Support Plugins ------
" https://github.com/fatih/vim-go
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
" https://github.com/hashivim/vim-terraform
Plug 'hashivim/vim-terraform'
" https://github.com/mattn/emmet-vim
Plug 'mattn/emmet-vim'

" Initialize plugin system
call plug#end()


""""""""""""""""""""""""""""""""
" General
""""""""""""""""""""""""""""""""
" Disable compatibility with vi which can cause unexpected issues.
set nocompatible

" show line numbers
set number 

" Do not save backup files.
set nobackup

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

" Function can be added to status line for a warning/error count
function! LinterStatus() abort
    let l:counts = ale#statusline#Count(bufnr(''))    
    let l:all_errors = l:counts.error + l:counts.style_error
    let l:all_non_errors = l:counts.total - l:all_errors    
    return l:counts.total == 0 ? 'OK' : printf(
        \   '%d⨉ %d⚠ ',
        \   all_non_errors,
        \   all_errors
        \)
endfunction
" set statusline+=%=
" set statusline+=\ %{LinterStatus()}

""""""""""""""""""""""""""""""""
" Plugin Configs
""""""""""""""""""""""""""""""""
" vim-terraform
let g:terraform_align=1 " align equal sings when saving
let g:terraform_fmt_on_save=1 " run fmt when saving

" ale
" Set this variable to 1 to fix files when you save them.
let g:ale_fix_on_save = 1
let g:ale_sign_error = '●'
let g:ale_sign_warning = '.'

" lightline
let g:lightline = {'colorscheme': 'solarized',}

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


