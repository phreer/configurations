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
  local force=$1
  local target=$2
  local link_pos=$3
  if [ "$force" -eq "0" ]; then
    ln -s "$target" "$link_pos" && echo 'Link ['"$target"'] to ['"$link_pos"']'
  else
    ln -sf "$target" "$link_pos" && echo 'Link ['"$target"'] to ['"$link_pos"']'
  fi
}

mkdir -p "$HOME"/.config/clash 2>/dev/null
mkdir -p "$HOME"/.config/fontconfig/conf.d 2>/dev/null
mkdir -p "$HOME"/.ssh 2>/dev/null
mkdir -p "$HOME"/local/bin 2>/dev/null

CreateSymbolicLink 1 "$SCRIPT_DIR/$INIT_FILENAME" "$HOME/init.sh"
source_command1=". $HOME/init.sh"
source_command2="source $HOME/init.sh"
source_command1='. $HOME/init.sh'
source_command2='source $HOME/init.sh'
if ! grep -E "$source_command"\|"$alt_source_command" "$HOME"/.bashrc >/dev/null; then
  echo Add command "$source_command1" to "$HOME"/.bashrc
  echo $source_command1 >> "$HOME"/.bashrc
fi

# Link directory
CreateSymbolicLink 1 "$SCRIPT_DIR"/../.config/nvim "$HOME"/.config/
CreateSymbolicLink 1 "$SCRIPT_DIR"/../.config/emacs "$HOME"/.config/
CreateSymbolicLink 1 "$SCRIPT_DIR"/../.config/tmux "$HOME"/.config/
CreateSymbolicLink 1 "$SCRIPT_DIR"/../.config/alacritty "$HOME"/.config/
# Only link some files
CreateSymbolicLink 1 "$SCRIPT_DIR"/../.config/clash/config.yaml "$HOME"/.config/clash/config.yaml
CreateSymbolicLink 1 "$SCRIPT_DIR"/../.config/clash/ruleset "$HOME"/.config/clash/
CreateSymbolicLink 1 "$SCRIPT_DIR"/../.config/fontconfig/conf.d/10-custom.conf \
    "$HOME"/.config/fontconfig/conf.d/
CreateSymbolicLink 1 "$SCRIPT_DIR"/../vim/.vimrc "$HOME"/.vimrc
CreateSymbolicLink 1 "$SCRIPT_DIR"/../.ssh/$SSH_CONFIG_FILE "$HOME"/.ssh/config
CreateSymbolicLink 1 "$SCRIPT_DIR"/../git/.gitconfig "$HOME"
CreateSymbolicLink 1 "$SCRIPT_DIR"/proxy.sh "$HOME"
CreateSymbolicLink 1 "$SCRIPT_DIR"/smart-pinentry.sh "$HOME"/local/bin/pinentry

cp "$SCRIPT_DIR"/../.config/systemd/user/uxplay.service "$HOME"/.config/systemd/user/uxplay.service
echo "Run systemctl enable --user uxplay.service to enable uxplay"
echo "Run systemctl start --user uxplay.service to start uxplay"
