local vim_map = vim.api.nvim_set_keymap

-- empty setup using defaults: add your own options
require('nvim-tree').setup {
}

-- ns for noremap and silent
local map_options_ns = {noremap = true, silent = true}
vim_map('n', '<C-n>', ':NvimTreeToggle<CR>', map_options_ns)
vim_map('n', '<M-n>', ':NvimTreeFindFileToggle<CR>', map_options_ns)

require('lualine').setup {
  -- options = {
  --   theme = 'onedark',
  -- }
}

local opt = require("toggleterm").setup({
  open_mapping = [[<Leader>t]],
  start_in_insert = true,
  direction = 'horizontal',
})

require('barbar_setting')
require('telescope_setting')
require('project_setting')
require('nvim-lspconfig_setting')
require('lspsaga_setting')
require('nvim-cmp_setting')
require('gitblame_setting')
require('symbols-outline_setting')
require("nvim-ufo_setting")

-- Setup theme
-- require('github-nvim-theme_setting')
-- require('nord-theme_setting')
-- require('zephyr-nvim-theme_setting')
require('gruvbox_setting')

require('nvim-treesitter_setting')
require('orgmode_setting')

require("indent_blankline").setup {
  -- for example, context is off by default, use this to turn it on
  show_current_context = true,
  show_current_context_start = true,
}

-- Bookmark setting
vim_map('n', '<leader>ma', ':BookmarkAnnotate<CR>', map_options_ns)
vim_map('n', '<leader>mt', ':BookmarkToggle<CR>', map_options_ns)
vim_map('n', '<leader>ms', ':BookmarkShowAll<CR>', map_options_ns)
vim_map('n', '<leader>mc', ':BookmarkClear<CR>', map_options_ns)
