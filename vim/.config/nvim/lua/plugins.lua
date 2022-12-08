local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

function in_vscode()
  return vim.g.vscode ~= nil
end

function not_in_vscode()
  return true
end

return require('packer').startup(function(use)
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
  }

  -- for fuzzy file searching
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} },
  }

  -- toggleterm.vim for internal terminal window
  use {
    "akinsho/toggleterm.nvim",
  }

  use 'neovim/nvim-lspconfig' -- Configurations for Nvim LSP

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)

