local vim_map = vim.api.nvim_set_keymap


-- empty setup using defaults: add your own options
require'nvim-tree'.setup {
}

require('lualine').setup {
  options = {
    theme = 'onedark',
  }
}

require('telescope').setup {
  pickers = {
    find_files = {
      follow = true,
    }
  },
}
-- ns for noremap and silent
local map_options_ns = {noremap = true, silent = true}
vim_map('n', '<C-n>', ':NvimTreeToggle<CR>', map_options_ns)
vim_map('n', '<Leader>ff', ':Telescope find_files<CR>', map_options_ns)
