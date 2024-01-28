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
  -- =========
  -- nvim-tree
  -- =========
  {
    'kyazdani42/nvim-tree.lua',
    dependencies = {
      'kyazdani42/nvim-web-devicons', -- optional, for file icon
    },
    config = require('config_nvim_tree'),
  },
  -- ======
  -- barbar
  -- ======
  {
    'romgrk/barbar.nvim',
    dependencies = {'kyazdani42/nvim-web-devicons'},
    config = require('config_barbar')
  },
  -- =========
  -- telesocpe
  -- =========
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
  'hrsh7th/cmp-path',     -- { name = 'path' }
  -- =========
  --   Theme
  -- =========
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'kyazdani42/nvim-web-devicons' },
  },
  { "ellisonleao/gruvbox.nvim", config = function() vim.cmd("colorscheme gruvbox") end },
})

