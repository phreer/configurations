local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
end

function in_vscode()
  return vim.g.vscode ~= nil
end

function not_in_vscode()
  return not in_vscode()
end

require('packer').startup(function(use)
  -- make sure to add this line to let packer manage itself
  use 'wbthomason/packer.nvim'

  -- nvim-tree.lua for file explorer
  use {
    'kyazdani42/nvim-tree.lua',
    requires = {
      'kyazdani42/nvim-web-devicons', -- optional, for file icon
    },
    config = function() require'nvim-tree'.setup {} end,
  }

  -- for tabbar
  use {
    'romgrk/barbar.nvim',
    requires = {'kyazdani42/nvim-web-devicons'},
  }

  -- for status line
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true },
    -- cond = not_in_vscode
  }

  -- for fuzzy file searching
  use {
    'nvim-telescope/telescope.nvim',
    requires = {
      {'nvim-lua/plenary.nvim'},
      {'nvim-telescope/telescope-live-grep-args.nvim' }
    },
  }

  use { "ahmedkhalf/project.nvim" }
  -- toggleterm.vim for internal terminal window
  use "akinsho/toggleterm.nvim"
  
  -- LSP config
  use 'neovim/nvim-lspconfig' -- Configurations for Nvim LSP
  use({
    "glepnir/lspsaga.nvim",
    branch = "main",
    config = function()
        require("lspsaga").setup({})
    end,
    requires = { {"nvim-tree/nvim-web-devicons"} }
  })

  -- For autocompletion setting
  use 'hrsh7th/nvim-cmp' -- Autocompletion
  use 'hrsh7th/cmp-nvim-lsp' -- { name = nvim_lsp }
  use 'hrsh7th/cmp-buffer'   -- { name = 'buffer' },
  use 'hrsh7th/cmp-path'     -- { name = 'path' }
  use 'hrsh7th/cmp-cmdline'  -- { name = 'cmdline' }

  -- vsnip
  use 'hrsh7th/cmp-vsnip'    -- { name = 'vsnip' }
  use 'hrsh7th/vim-vsnip'
  use 'rafamadriz/friendly-snippets'

  -- Git integration
  use 'f-person/git-blame.nvim'

  -- Themes
  use 'projekt0n/github-nvim-theme'
  use 'shaunsingh/nord.nvim'
  use({
    'glepnir/zephyr-nvim',
    requires = { 'nvim-treesitter/nvim-treesitter', opt = true },
  })
  use { "ellisonleao/gruvbox.nvim" }

  -- For outline
  use 'simrat39/symbols-outline.nvim'

  -- For treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }
  use 'nvim-treesitter/nvim-treesitter-context'
  
  use "lukas-reineke/indent-blankline.nvim"

  use {
    'nvim-orgmode/orgmode',
    config = function()
      require('orgmode').setup{}
    end
  }

  use 'MattesGroeger/vim-bookmarks'

  -- Modern folding style
  use {'kevinhwang91/nvim-ufo', requires = 'kevinhwang91/promise-async'}

  -- use { 'fgheng/winbar.nvim' }
  -- use { 'zefei/vim-wintabs' }
  -- use { 'zefei/vim-wintabs-powerline' }

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)


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

require("ibl").setup {
}

-- Bookmark setting
vim_map('n', '<leader>ma', ':BookmarkAnnotate<CR>', map_options_ns)
vim_map('n', '<leader>mt', ':BookmarkToggle<CR>', map_options_ns)
vim_map('n', '<leader>ms', ':BookmarkShowAll<CR>', map_options_ns)
vim_map('n', '<leader>mc', ':BookmarkClear<CR>', map_options_ns)
