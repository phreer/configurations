set nocompatible              " be iMproved, required

set relativenumber
set nu

set ts=8 " aka tabstop
set sts=2 " aka softtabstop
set sw=2 " aka shiftwidth
set noexpandtab

set autoindent
set smartindent
set smarttab

set hidden
set colorcolumn=80
" Highlight current line
set cursorline
set foldlevel=99
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
" Use Ctrl-s to save file
inoremap <C-s> <Esc>:w<CR>a
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
  source ~/.vim/plugin.vim
end
