set nocompatible
syntax enable
set encoding=utf-8
set showcmd
filetype plugin indent on

set nowrap
set tabstop=4 shiftwidth=4
set expandtab
set backspace=indent,eol,start

set hlsearch
set incsearch
set ignorecase
set smartcase

highlight OverLength ctermbg=red ctermfg=white guibg=#592929
match OverLength /\%81v.\+/
