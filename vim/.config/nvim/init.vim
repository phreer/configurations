set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

let g:vimsyn_embed = 'lPr'
" For plug-ins manager packer.
lua require('plugins')
" My personal configurations in lua.
lua require('phree_init')
