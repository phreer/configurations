local vim_map = vim.api.nvim_set_keymap

-- empty setup using defaults: add your own options
require('nvim-tree').setup {
}

-- ns for noremap and silent
local map_options_ns = {noremap = true, silent = true}
vim_map('n', '<C-n>', ':NvimTreeToggle<CR>', map_options_ns)

require('lualine').setup {
  options = {
    theme = 'onedark',
  }
}

local opt = require("toggleterm").setup({
    open_mapping = [[<Leader>t]],
    start_in_insert = true,
    direction = 'horizontal',
})

require('barbar_setting')
require('telescope_setting')
require('nvim-lspconfig_setting')
require('nvim-cmp_setting')
require('gitblame_setting')
require('symbols-outline_setting')

-- Setup theme
-- require('github-nvim-theme_setting')
-- require('nord-theme_setting')
require('zephyr-nvim-theme_setting')

require('nvim-treesitter_setting')
require('orgmode_setting')