" .vimrc of Technat (Server-Edition, https://git.technat.ch/technat/WALL-E)
" credits to https://github.com/amix/vimrc (used as inspiration)

""""""""""""""""""""""""""""""""
" General
""""""""""""""""""""""""""""""""
" Set utf8 as standard encoding
set encoding=utf8
" Use Unix as the standard file type
set ffs=unix,dos,mac
" show line numbers
set number 
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
noremap <silent> <leader>nl :leftabove vnew<cr>
noremap <silent> <leader>nr :rightbelow vnew<cr>
noremap <silent> <leader>na :leftabove new<cr>
noremap <silent> <leader>nb :rightbelow new<cr>
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
noremap <silent> <leader>jj <c-w>w<c-d><c-w>W
noremap <silent> <leader>kk <c-w>w<c-u><c-w>W

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
colorscheme zellner

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
