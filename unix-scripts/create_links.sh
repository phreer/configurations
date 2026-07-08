#!/bin/bash
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

source "$SCRIPT_DIR/lib/symlink_utils.sh"
source "$SCRIPT_DIR/lib/log_utils.sh"

# For bash
OS=$(uname)
if [ "$OS" = "Linux" ]; then
  PREFIX_OS=linux
elif [ "$OS" = "Darwin" ]; then
  PREFIX_OS=osx
else
  echo "Unsupported OS: " $OS
  exit 1
fi

INIT_DIR=$HOME/.init
SSH_CONFIG_FILE="$PREFIX_OS"-config
GIT_CONFIG_FILE="$PREFIX_OS".gitconfig

CopyFileIfNotExist() {
  local src=$1
  local dst=$2
  if [ ! -e "$2" ]; then
    cp "$src" "$dst" && echo "Copy [$src] => [$dst]"
  else
    LogWarning "[$dst] exists, skip copying"
  fi
}


# Setup init scripts for bash and zsh
CreateSymbolicLink 1 "$SCRIPT_DIR/init" "$INIT_DIR"

# Add `source $HOME/$PREFIX_OS-init.$SUFFIX_SHELL` to .bashrc/.zshrc if it does
# not exist
AddSourceCommand() {
  local suffix_shell=$1
  local target_file="$HOME"/$2
  local source_command1="source \$__INIT_DIR/$PREFIX_OS-init.$suffix_shell"
  local source_command2=". \$__INIT_DIR/$PREFIX_OS-init.$suffix_shell"
  if [ ! -e "$target_file" ]; then
    LogWarning "$target_file does not exist, skipping adding source command"
    return
  fi
  if ! grep -e "$source_command1" -e "$source_command2" "$target_file" >/dev/null; then
    echo Add command "$source_command1" to "$target_file"
    echo "__INIT_DIR=\$HOME/.init" >> "$target_file"
    echo $source_command1 >> "$target_file"
  fi
}

SUFFIX_SHELLS=( "sh" "zsh" )
SHELL_RC_FILES=( ".bashrc" ".zshrc" )

for i in `seq 0 $(( ${#SUFFIX_SHELLS[@]} - 1 ))`; do
  AddSourceCommand ${SUFFIX_SHELLS[$i]} ${SHELL_RC_FILES[$i]}
done

# Link directory
CreateSymbolicLink 0 "$SCRIPT_DIR"/../.config/nvim "$HOME"/.config/
CreateSymbolicLink 0 "$SCRIPT_DIR"/../.config/emacs "$HOME"/.config/
CreateSymbolicLink 0 "$SCRIPT_DIR"/../.config/tmux "$HOME"/.config/
CreateSymbolicLink 0 "$SCRIPT_DIR"/../.config/alacritty "$HOME"/.config/
CreateSymbolicLink 0 "$SCRIPT_DIR"/../.config/kitty "$HOME"/.config/
CreateSymbolicLink 1 "${PREFIX_OS}.conf" "$HOME"/.config/kitty/kitty-local.conf
CreateSymbolicLink 0 "$SCRIPT_DIR"/../fonts/NerdFontSymbols "$HOME"/.local/share/fonts/

# Only link some files
# Agents
CreateSymbolicLink 1 "$SCRIPT_DIR"/../GLOBAL_AGENTS.md "$HOME"/.config/opencode/AGENTS.md
CreateSymbolicLink 1 "$SCRIPT_DIR"/../GLOBAL_AGENTS.md "$HOME"/.claude/CLAUDE.md
CreateSymbolicLink 1 "$SCRIPT_DIR"/../.config/opencode/opencode.json "$HOME"/.config/opencode/
mkdir "$HOME"/.claude 2>/dev/null || true
CreateSymbolicLink 0 "$SCRIPT_DIR"/../ai-agents/skills "$HOME"/.claude/

CreateSymbolicLink 1 "$SCRIPT_DIR"/../.config/clash/ruleset "$HOME"/.config/clash/
CreateSymbolicLink 0 "$SCRIPT_DIR"/../.config/fontconfig/conf.d/10-custom.conf \
    "$HOME"/.config/fontconfig/conf.d/
CreateSymbolicLink 0 "$SCRIPT_DIR"/../vim/.vimrc "$HOME"/
CreateSymbolicLink 1 "$SCRIPT_DIR"/../vim/.vim "$HOME"/
CreateSymbolicLink 1 "$SCRIPT_DIR"/proxy.sh "$HOME"/
CreateSymbolicLink 0 "$SCRIPT_DIR"/../.config/systemd/user/uxplay.service \
    "$HOME"/.config/systemd/user/uxplay.service

CreateSymbolicLink 0 "$SCRIPT_DIR"/helper/smart-pinentry.sh "$HOME"/local/bin/pinentry
CreateSymbolicLink 0 "$SCRIPT_DIR"/helper/mvln "$HOME"/local/bin/

CreateSymbolicLink 0 "$SCRIPT_DIR"/../etc/ssh/$SSH_CONFIG_FILE "$HOME"/.ssh/config
mkdir "$HOME"/.ssh/conf.d 2>/dev/null || true

# Git config
# OS specific config
CreateSymbolicLink 0 "$SCRIPT_DIR"/../etc/git/$GIT_CONFIG_FILE "$SCRIPT_DIR"/../etc/git/os.conf
# Generic config
CreateSymbolicLink 0 "$SCRIPT_DIR"/../etc/git "$HOME"/.config/git

# CopyFileIfNotExist "$SCRIPT_DIR"/../.config/clash/config.yaml "$HOME"/.config/clash/config.yaml

