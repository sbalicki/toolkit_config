" This line should not be removed as it ensures that various options are
" properly set to work with the Vim-related packages available in Debian.
runtime! debian.vim

" Load pathogen plugin (https://github.com/tpope/vim-pathogen)
execute pathogen#infect()

" Syntax highlighting
syntax on

" Enable solarized theme
set background=dark
set t_Co=256
let g:solarized_termcolors=256
colorscheme solarized

" Uncomment the following to have Vim jump to the last position when
" reopening a file
"if has("autocmd")
"  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
"endif

" Load indentation rules and plugins according to the detected filetype.
"if has("autocmd")
filetype plugin indent on
"endif

"Set indentation to 4 spaces
set tabstop=4 " Will show existing tab with 4 spaces width
set shiftwidth=4
set expandtab

" Enable useful features
set showcmd		" Show (partial) command in status line.
set showmatch		" Show matching brackets.
"set ignorecase		" Do case insensitive matching
"set smartcase		" Do smart case matching
"set incsearch		" Incremental search
"set autowrite		" Automatically save before commands like :next and :make
"set hidden		" Hide buffers when they are abandoned
"set mouse=a		" Enable mouse usage (all modes)

" Source a global configuration file if available
if filereadable("/etc/vim/vimrc.local")
  source /etc/vim/vimrc.local
endif

" Set path to ctags file
set tags=./tags;,tags;

" Enable clang-format shortcuts
map <C-K> :py3f $HOME/clang-format.py<cr>
imap <C-K> <c-o>:py3f $HOME/clang-format.py<cr>
" Enable clang-format autoformat on save
function! Formatonsave()
  let l:formatdiff = 1
    py3f $HOME/clang-format.py
endfunction
autocmd BufWritePre *.hpp,*.h,*.c,*.cc,*.cpp call Formatonsave()
