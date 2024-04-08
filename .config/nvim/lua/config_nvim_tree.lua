return function()
  local function set_nvim_tree_mapping(bufnr)
    local api = require "nvim-tree.api"
  
    local function opts(desc)
      return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end
  
    -- default mappings
    api.config.mappings.default_on_attach(bufnr)
  end

  require'nvim-tree'.setup {
    on_attach = set_nvim_tree_mapping
  }

  local vim_map = vim.api.nvim_set_keymap
  -- ns for noremap and silent
  local map_options_ns = {noremap = true, silent = true}
  vim_map('n', '<C-n>', ':NvimTreeToggle<CR>', map_options_ns)
  vim_map('n', '<M-n>', ':NvimTreeFindFileToggle<CR>', map_options_ns)
end
