#!/bin/bash

# Exit upon error
set -e

curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
mkdir -p "$HOME/local" 2>/dev/null || true
if [ -d "$HOME/local/nvim-linux-x86_64" ]; then
	echo "Old nvim installation found, remove and install? (y/n)"
	read -r answer
	if [ "$answer" != "y" ]; then
		echo "Aborting installation."
		exit 1
	fi
	rm -rf "$HOME/local/nvim-linux-x86_64"
fi
tar -C $HOME/local/ -xzf nvim-linux-x86_64.tar.gz
mkdir -p "$HOME/local/bin" 2>/dev/null || true
ln -sf "$HOME/local/nvim-linux-x86_64/bin/nvim" "$HOME/local/bin/nvim"
echo "Neovim installed to $HOME/local/nvim-linux-x86_64"
rm nvim-linux-x86_64.tar.gz
