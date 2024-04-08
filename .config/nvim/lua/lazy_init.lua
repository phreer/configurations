local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- =============
  --   nvim-tree
  -- =============
  {
    'kyazdani42/nvim-tree.lua',
    dependencies = {
      'kyazdani42/nvim-web-devicons', -- optional, for file icon
    },
    config = require('config_nvim_tree'),
  },
  -- ==========
  --   barbar
  -- ==========
  {
    'romgrk/barbar.nvim',
    dependencies = {'kyazdani42/nvim-web-devicons'},
    config = require('config_barbar')
  },
  -- =============
  --   telesocpe
  -- =============
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      {'nvim-lua/plenary.nvim'},
      {'nvim-telescope/telescope-live-grep-args.nvim' }
    },
    config = require('config_telescope'),
  },
  -- ==============
  --   Completion
  -- ==============
  'hrsh7th/cmp-nvim-lsp', -- { name = nvim_lsp }
  'hrsh7th/cmp-buffer',   -- { name = 'buffer' },
  'hrsh7th/cmp-path',     -- { name = 'path' }
  'hrsh7th/cmp-cmdline',  -- { name = 'cmdline' }
  'hrsh7th/cmp-path',     -- { name = 'path' }
  {
    'hrsh7th/nvim-cmp', -- Autocompletion
    config = require('config_nvim_cmp'),
  },
  -- =========
  --   Theme
  -- =========
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'kyazdani42/nvim-web-devicons' },
  },
  { "ellisonleao/gruvbox.nvim", config = function() vim.cmd("colorscheme gruvbox") end },
  -- ========================
  --   Modern folding style
  -- ========================
  {
    'kevinhwang91/nvim-ufo',
    dependencies = 'kevinhwang91/promise-async',
    config = require('config_nvim_ufo'),
  },
  {
    'f-person/git-blame.nvim',
    config = function()
      require('gitblame')
    end,
  },
  -- =======
  --   LSP
  -- =======
  'neovim/nvim-lspconfig', -- Configurations for Nvim LSP
  {
    "glepnir/lspsaga.nvim",
    config = require('config_lspsaga'),
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    config = function()
      require("ibl").setup()
    end,
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
  'simrat39/symbols-outline.nvim',
  {
    'nvim-treesitter/nvim-treesitter',
    build = ":TSUpdate",
    config = require('config_treesitter'),
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    config = require('config_treesitter-context'),
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
  {
    'mhartington/formatter.nvim',
    config = require('config_formatter'),
  },
})

