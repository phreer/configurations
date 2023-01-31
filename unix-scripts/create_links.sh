#!/usr/bin/bash
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

mkdir -p "$HOME"/local/bin 2>/dev/null

# For bash
OS=$(uname)
if [ "$OS" = "Linux" ]; then
	PREFIX=linux
elif [ "$OS" = "Darwin" ]; then
	prefix=osx
else
	echo "Unsupported OS: " $OS
	exit 1
fi

INIT_FILENAME="$PREFIX""-init.sh"
SSH_CONFIG_FILE="$PREFIX"-config

function CreateSymbolicLink() {
  local target=$1
  local link_pos=$2
  if [ -f "$link_pos" ]; then
    echo 'Trying to link ['"$target"'] to ['"$link_pos"'], but '"$link_pos"' exists already.'
  else
    ln -s "$target" "$link_pos"
  fi
}

CreateSymbolicLink "$SCRIPT_DIR/$INIT_FILENAME" "$HOME/init.sh"
source_command1=". $HOME/init.sh"
source_command2="source $HOME/init.sh"
source_command1='. $HOME/init.sh'
source_command2='source $HOME/init.sh'
if ! grep -E "$source_command"\|"$alt_source_command" "$HOME"/.bashrc >/dev/null; then
  echo Add command "$source_command1" to "$HOME"/.bashrc
	echo $source_command1 >> "$HOME"/.bashrc
fi

# For vim and neovim
CreateSymbolicLink "$SCRIPT_DIR"/../vim/.config/nvim "$HOME"/.config/
CreateSymbolicLink "$SCRIPT_DIR"/../vim/.config/tmux "$HOME"/.config/
CreateSymbolicLink "$SCRIPT_DIR"/../vim/.vimrc "$HOME"/.vimrc
CreateSymbolicLink "$SCRIPT_DIR"/../.ssh/$SSH_CONFIG_FILE "$HOME"/.ssh/config
CreateSymbolicLink "$SCRIPT_DIR"/../git/.gitconfig "$HOME"/.gitconfig
CreateSymbolicLink "$SCRIPT_DIR"/proxy.sh "$HOME"/proxy.sh
CreateSymbolicLink "$SCRIPT_DIR"/smart-pinentry.sh "$HOME"/local/bin/pinentry
