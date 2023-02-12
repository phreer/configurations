require('telescope').setup {
  pickers = {
    find_files = {
      follow = true,
      hidden = true,
    }
  },
}

require("telescope").load_extension("live_grep_args")
require('telescope').load_extension('projects')
local builtin = require('telescope.builtin')
local extensions = require('telescope').extensions

vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fs', builtin.grep_string, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>fr', builtin.resume, {})
vim.keymap.set('n', '<leader>fp', extensions.projects.projects, {})
vim.keymap.set("n", "<leader>fg", extensions.live_grep_args.live_grep_args, {})
