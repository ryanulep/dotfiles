set encoding=utf-8

set backspace=indent,eol,start " Backspace deletes like most programs in insert mode
set history=1000
set laststatus=2              " Always display the status line
set showcmd                   " Display incomplete commands
set relativenumber number     " Displays both absolute and relative line numbers
set autoindent                " Auto indent (smartindent is deprecated; filetype indent handles it)
set smarttab                  " Tab and backspace are smart
set ruler                     " Show line and column number in status bar
set scrolloff=8               " Keep 8 lines of context around the cursor

set shell=zsh
filetype on                   " Enable filetype detection
filetype indent on            " Enable filetype-specific indenting
filetype plugin on            " Enable filetype-specific plugins
syntax on                     " Enable syntax highlighting

" Change cursor to pipe for insert mode
let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_SR = "\<Esc>]50;CursorShape=2\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"

" Softtabs, 2 spaces
set tabstop=2
set shiftwidth=2
set shiftround
set expandtab

" Search
set incsearch                 " Highlight matches as you type
set hlsearch                  " Highlight all matches
set ignorecase                " Case-insensitive search...
set smartcase                 " ...unless the query contains uppercase

" Files and buffers
set hidden                    " Allow switching buffers without saving
set autoread                  " Reload files changed outside vim
set clipboard=unnamed         " Yank/paste to/from system clipboard
set updatetime=300            " Faster swap writes and plugin responsiveness (default 4000ms)

" Persistent undo across sessions
set undofile
set undodir=~/.vim/undo

" Command-line completion
set wildmenu                  " Enhanced command-line completion
set wildmode=list:longest     " Complete to longest common match, then list

" Splits open in a more natural direction
set splitbelow
set splitright

" True color support (works inside tmux with: set -g default-terminal "tmux-256color")
if has("termguicolors")
  set termguicolors
endif

" Local config
if filereadable($HOME . "/.vimrc.local")
  source ~/.vimrc.local
endif
