set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

" Load global vim setting
source ~/.vimrc

let g:vimsyn_embed = 'lPr'
" For plug-ins manager packer.
lua require('plugins')
" My personal configurations in lua.
lua require('phree_init')

set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set foldlevel=99
" Disable folding at startup.
set nofoldenable

if exists("g:neovide")
  " Put anything you want to happen only in Neovide here
	let g:neovide_scale_factor = 1.5
	" set lines=50
  " set columns=120
  let g:neovide_remember_window_size = v:true
endif

map <C-H> <Plug>(wintabs_previous)
map <C-L> <Plug>(wintabs_next)
map <C-T>c <Plug>(wintabs_close)
map <C-T>u <Plug>(wintabs_undo)
map <C-T>o <Plug>(wintabs_only)
map <C-W>c <Plug>(wintabs_close_window)
map <C-W>o <Plug>(wintabs_only_window)
command! Tabc WintabsCloseVimtab
command! Tabo WintabsOnlyVimtab

" Load project specific vim setting
set secure
set exrc
