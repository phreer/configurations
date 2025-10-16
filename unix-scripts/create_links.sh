#!/bin/bash
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

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

SSH_CONFIG_FILE="$PREFIX_OS"-config
GIT_CONFIG_FILE="$PREFIX_OS".gitconfig

CopyFileIfNotExist() {
  local src=$1
  local dst=$2
  if [ ! -e "$2" ]; then
    cp "$src" "$dst" && echo "Copy [$src] to [$dst]"
  else
    echo "File [$dst] exists, skip copying"
  fi
}

CreateSymbolicLink() {
  local force=$1
  local target=$2
  local link_pos=$3
  local link_dir
  if [ "${link_pos: -1}" = "/" ]; then
    link_dir="$link_pos"
  elif [ -d "${link_pos}" ]; then
    link_dir="$link_pos"
  elif [ -e "${link_pos}" ] && [ ! "$force" = "1" ]; then
    echo "$link_pos is not a directory!" >&2
    return
  else
    link_dir="${link_pos%/*}"
  fi

  if [ ! -e "$link_dir" ]; then
    mkdir -p "$link_dir" 2> /dev/null
  fi

  if [ "$force" -eq "0" ]; then
    ln -s "$target" "$link_dir"/ && echo 'Link ['"$target"'] to ['"$link_pos"']'
  else
    ln -sf "$target" "$link_dir"/ && echo 'Link ['"$target"'] to ['"$link_pos"']'
  fi
}

# Setup init scripts for bash and zsh
CreateSymbolicLink 1 "$SCRIPT_DIR/init.rc" "$HOME"/
CreateSymbolicLink 1 "$SCRIPT_DIR/$PREFIX_OS-init.rc" "$HOME"/

# Add `source $HOME/$PREFIX_OS-init.$SUFFIX_SHELL` to .bashrc/.zshrc if it does
# not exist
AddSourceCommand() {
  local suffix_shell=$1
  local target_file="$HOME"/$2
  local source_command1="source \$HOME/$PREFIX_OS-init.$suffix_shell"
  local source_command2=". \$HOME/$PREFIX_OS-init.$suffix_shell"
  if ! grep -e "$source_command1" -e "$source_command2" "$target_file" >/dev/null; then
    echo Add command "$source_command1" to "$target_file"
    echo $source_command1 >> "$target_file"
  fi
}

SUFFIX_SHELLS=( "sh" "zsh" )
SHELL_RC_FILES=( ".bashrc" ".zshrc" )

for i in `seq 0 $(( ${#SUFFIX_SHELLS[@]} - 1 ))`; do
  CreateSymbolicLink 1 "$SCRIPT_DIR/init.${SUFFIX_SHELLS[i]}" "$HOME"
  CreateSymbolicLink 1 "$SCRIPT_DIR/$PREFIX_OS-init.${SUFFIX_SHELLS[i]}" "$HOME"
  AddSourceCommand ${SUFFIX_SHELLS[$i]} ${SHELL_RC_FILES[$i]}
done

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
CreateSymbolicLink 0 "$SCRIPT_DIR"/../vim/.vimrc "$HOME"/
CreateSymbolicLink 1 "$SCRIPT_DIR"/../vim/.vim "$HOME"/
CreateSymbolicLink 1 "$SCRIPT_DIR"/proxy.sh "$HOME"/
CreateSymbolicLink 1 "$SCRIPT_DIR"/smart-pinentry.sh "$HOME"/local/bin/pinentry
CreateSymbolicLink 0 "$SCRIPT_DIR"/../.config/systemd/user/uxplay.service \
    "$HOME"/.config/systemd/user/uxplay.service

CreateSymbolicLink 0 "$SCRIPT_DIR"/helper/smart-pinentry.sh "$HOME"/local/bin/pinentry
CreateSymbolicLink 0 "$SCRIPT_DIR"/helper/mvln "$HOME"/local/bin/

CreateSymbolicLink 0 "$SCRIPT_DIR"/../etc/ssh/$SSH_CONFIG_FILE "$HOME"/.ssh/config
# OS specific config
CreateSymbolicLink 0 "$SCRIPT_DIR"/../etc/git/$GIT_CONFIG_FILE "$HOME"/os.gitconfig
# Generic config
CreateSymbolicLink 0 "$SCRIPT_DIR"/../etc/git/.gitconfig "$HOME"/.gitconfig

# CopyFileIfNotExist "$SCRIPT_DIR"/../.config/clash/config.yaml "$HOME"/.config/clash/config.yaml

echo "Run systemctl enable --user uxplay.service to enable uxplay"
echo "Run systemctl start --user uxplay.service to start uxplay"
