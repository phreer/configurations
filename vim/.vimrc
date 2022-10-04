set nocompatible              " be iMproved, required

set nu
set autoindent
set expandtab
set softtabstop=2
set ts=2
set sw=2
set autoindent
set smartindent
set smarttab
set colorcolumn=80
" Highlight current line
set cursorline

" set spelllang=en
" set spell

" map <C-n> :NERDTree<CR>
" Open NerdTree on startup. 
" autocmd vimenter * NERDTree
" autocmd vimenter * wincmd w
" autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" In insert or command mode, move normally by using Ctrl
inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>
cnoremap <C-h> <Left>
cnoremap <C-j> <Down>
cnoremap <C-k> <Up>
cnoremap <C-l> <Right>

set mouse=a
if !has("nvim")
if has("mouse_sgr")
    set ttymouse=sgr
else
    set ttymouse=xterm2
end
end
