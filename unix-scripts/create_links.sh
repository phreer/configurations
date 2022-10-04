#!/usr/bin/bash
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

# For bash
OS=$(uname)
if [ "$OS" = "Linux"]; then
	INIT_FILENAME="linux-init.sh"
elif [ "$OS" = "Darwin" ]; then
	INIT_FILENAME="osx-init.sh"
fi

if [ ! -f "$HOME/init.sh" ]; then
	ln -s "$SCRIPT_DIR/$INIT_FILENAME" "$HOME/init.sh"
	echo ". $HOME/init.sh" >> "$HOME/.bashrc"
fi

# For vim and neovim
if [ ! -f "$HOME/.vimrc" ]; then
	ln -s "$SCRIPT_DIR/../vim/.vimrc" "$HOME/.vimrc"
fi
mkdir -p "$HOME/.conf/nvim" 2>/dev/null
if [ ! -f "$HOME/.conf/init.vim" ]; then
	ln -s "$SCRIPT_DIR/../vim/.config/nvim/init.vim" "$HOME/.conf/nvim/init.vim"
	ln -s "$SCRIPT_DIR/../vim/.config/nvim/lua" "$HOME/.conf/nvim/lua"
fi

# For proxy
[ ! -f "$HOME/proxy.sh" ] && ln -s "$SCRIPT_DIR/proxy.sh" "$HOME/proxy.sh"

