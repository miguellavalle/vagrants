" Enable syntax highlighting
syntax enable

" Enable file type detection and language-dependent indenting/plugins
filetype plugin indent on

" Display line numbers
set number

" Set tab character width to 4 spaces (Python standard)
set tabstop=4

" Set number of spaces to use for each step of (auto)indent
set shiftwidth=4

" Use spaces instead of tabs for indentation
set expandtab
"
" Enable intelligent indentation (works with Python syntax)
set autoindent
set smartindent

" Make backspace behave more like a normal editor
set backspace=indent,eol,start

" Allow saving changes even when other buffers are open
set hidden

" Set search highlighting and incremental search
set hlsearch
set incsearch

" Enable the status line to always be visible
set laststatus=2

" Enable the bundled editorconfig plugin
packadd! editorconfig
