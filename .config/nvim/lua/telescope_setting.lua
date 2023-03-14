require('telescope').setup {
  defaults = {
    theme = "dropdown",
    file_ignore_patterns = { ".git/*" },
    follow = true,
    hidden = true,
  },
  pickers = {
    find_files = {
      theme = "dropdown",
    follow = true,
    hidden = true,
    },
  },
  extensions = {
    live_grep_args = {
      theme = "dropdown"
    },
  },
}

require("telescope").load_extension("live_grep_args")
local builtin = require('telescope.builtin')
local extensions = require('telescope').extensions

vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fs', builtin.grep_string, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>fr', builtin.resume, {})
vim.keymap.set("n", "<leader>fg", extensions.live_grep_args.live_grep_args, {})
