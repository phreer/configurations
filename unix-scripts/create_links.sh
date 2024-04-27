#!/bin/bash
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

mkdir -p "$HOME"/local/bin 2>/dev/null

# For bash
OS=$(uname)
if [ "$OS" = "Linux" ]; then
  OS_PREFIX=linux
elif [ "$OS" = "Darwin" ]; then
  OS_PREFIX=osx
else
  echo "Unsupported OS: " $OS
  exit 1
fi

BASHRC="$OS_PREFIX""-init.sh"
ZSHRC="$OS_PREFIX""-init.zsh"
SSH_CONFIG_FILE="$OS_PREFIX"-config

function CopyFileIfNotExist() {
  local src=$1
  local dst=$2
  if [ ! -e "$2" ]; then
    cp "$src" "$dst"
    echo "Copy [$src] to [$dst]"
  else
    echo "File [$dst] exists, skip copying"
  fi
}

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
mkdir -p "$HOME"/.local/share/fonts 2>/dev/null

# Setup init scripts for bash and zsh
CreateSymbolicLink 1 "$SCRIPT_DIR/linux-init-common.sh" "$HOME"/init-common.sh
CreateSymbolicLink 1 "$SCRIPT_DIR/$BASHRC" "$HOME"/init.sh
CreateSymbolicLink 1 "$SCRIPT_DIR/$ZSHRC" "$HOME"/init.zsh

# Add `source $HOME/init.sh` to .bashrc if not exists
SOURCE_COMMAND1='source $HOME/init.sh'
SOURCE_COMMAND2='. $HOME/init.sh'
TARGET_FILE="$HOME"/.bashrc
if ! grep -e "$SOURCE_COMMAND1" -e "$SOURCE_COMMAND2" "$TARGET_FILE" >/dev/null; then
  echo Add command "$SOURCE_COMMAND1" to "$TARGET_FILE"
  echo $SOURCE_COMMAND1 >> "$TARGET_FILE"
fi

SOURCE_COMMAND1='source $HOME/init.zsh'
SOURCE_COMMAND2='. $HOME/init.zsh'
TARGET_FILE="$HOME"/.zshrc
if ! grep -e "$SOURCE_COMMAND1" -e "$SOURCE_COMMAND2" "$TARGET_FILE" >/dev/null; then
  echo Add command "$SOURCE_COMMAND1" to "$TARGET_FILE"
  echo $SOURCE_COMMAND1 >> "$TARGET_FILE"
fi

# Link directory
CreateSymbolicLink 0 "$SCRIPT_DIR"/../.config/nvim "$HOME"/.config/
CreateSymbolicLink 0 "$SCRIPT_DIR"/../.config/emacs "$HOME"/.config/
CreateSymbolicLink 0 "$SCRIPT_DIR"/../.config/tmux "$HOME"/.config/
CreateSymbolicLink 0 "$SCRIPT_DIR"/../.config/alacritty "$HOME"/.config/
CreateSymbolicLink 0 "$SCRIPT_DIR"/../fonts/NerdFontSymbols "$HOME"/.local/share/fonts/

# Only link some files
CreateSymbolicLink 1 "$SCRIPT_DIR"/../.config/clash/ruleset "$HOME"/.config/clash/
CreateSymbolicLink 0 "$SCRIPT_DIR"/../.config/fontconfig/conf.d/10-custom.conf \
    "$HOME"/.config/fontconfig/conf.d/
CreateSymbolicLink 0 "$SCRIPT_DIR"/../vim/.vimrc "$HOME"
CreateSymbolicLink 1 "$SCRIPT_DIR"/../vim/.vim "$HOME"
CreateSymbolicLink 1 "$SCRIPT_DIR"/proxy.sh "$HOME"
CreateSymbolicLink 1 "$SCRIPT_DIR"/smart-pinentry.sh "$HOME"/local/bin/pinentry
CreateSymbolicLink 0 "$SCRIPT_DIR"/../.config/systemd/user/uxplay.service \
    "$HOME"/.config/systemd/user/uxplay.service

CopyFileIfNotExist "$SCRIPT_DIR"/../.ssh/$SSH_CONFIG_FILE "$HOME"/.ssh/config
CopyFileIfNotExist "$SCRIPT_DIR"/../git/.gitconfig "$HOME"/.gitconfig
CopyFileIfNotExist "$SCRIPT_DIR"/../.config/clash/config.yaml "$HOME"/.config/clash/config.yaml

echo "Run systemctl enable --user uxplay.service to enable uxplay"
echo "Run systemctl start --user uxplay.service to start uxplay"
