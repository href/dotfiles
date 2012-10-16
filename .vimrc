set nocompatible
syntax enable
set encoding=utf-8
set showcmd
filetype plugin indent on

set nowrap
set tabstop=4 shiftwidth=4
set expandtab
set backspace=indent,eol,start
set showcmd

inoremap jj <ESC>

set hlsearch
set incsearch
set ignorecase
set smartcase

highlight OverLength ctermbg=red ctermfg=white guibg=#592929
match OverLength /\%81v.\+/

 set t_Co=8
 set t_Sb=^[4%dm
 set t_Sf=^[3%dm
 :imap <Esc>Oq 1
 :imap <Esc>Or 2
 :imap <Esc>Os 3
 :imap <Esc>Ot 4
 :imap <Esc>Ou 5
 :imap <Esc>Ov 6
 :imap <Esc>Ow 7
 :imap <Esc>Ox 8
 :imap <Esc>Oy 9
 :imap <Esc>Op 0
 :imap <Esc>On .
 :imap <Esc>OQ /
 :imap <Esc>OR *
 :imap <Esc>Ol +
 :imap <Esc>OS -
