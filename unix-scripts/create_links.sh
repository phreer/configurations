#!/usr/bin/bash
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

# For bash
OS=$(uname)
if [ "$OS" = "Linux" ]; then
	PREFIX=linux
	INIT_FILENAME="linux-init.sh"
elif [ "$OS" = "Darwin" ]; then
	prefix=osx
else
	echo "Unsupported OS: " $OS
	exit 1
fi

INIT_FILENAME="$PREFIX""-init.sh"

if [ ! -f "$HOME/init.sh" ]; then
	ln -s "$SCRIPT_DIR/$INIT_FILENAME" "$HOME/init.sh"
	echo ". $HOME/init.sh" >> "$HOME/.bashrc"
fi

# For vim and neovim
if [ ! -f "$HOME/.vimrc" ]; then
	ln -s "$SCRIPT_DIR/../vim/.vimrc" "$HOME/.vimrc"
fi

if [ -f "$HOME/.config/nvim" ]; then
	echo "Directory $HOME/.config/nvim already exists. Skip to link."
else
	ln -s "$SCRIPT_DIR"/../vim/.config/nvim "$HOME"/.config/
fi

# For proxy
[ ! -f "$HOME/proxy.sh" ] && ln -s "$SCRIPT_DIR/proxy.sh" "$HOME/proxy.sh"

# For SSH configuration
SSH_CONFIG_FILE="$PREFIX"-config
if [ ! -f "$HOME"/.ssh/config ]; then
	ln -s "$SCRIPT_DIR"/../.ssh/$SSH_CONFIG_FILE "$HOME"/.ssh/config
else
	echo "File " "$HOME"/.ssh/config "existed. Skip to link." 
fi

