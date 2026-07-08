source "$(dirname "${BASH_SOURCE[0]}")/log_utils.sh"

ShowPathInfo() {
  local path=$1

  LogInfo "[$path] already exists:"
  ls -ld -- "$path"
  if [ -L "$path" ]; then
    LogInfo "symlink target: $(readlink "$path")"
  elif [ -d "$path" ]; then
    LogInfo "contents of the directory:"
    ls -a "$path"
  fi
}

ConfirmOverwrite() {
  local path=$1
  local answer

  read -r -p "Overwrite [$path]? [y/N]: " answer
  case "$answer" in
    y|Y)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

ReplaceWithSymlink() {
  local target=$1
  local path=$2
  local resolved_target
  local resolved_path

  if [ "$target" = "$path" ]; then
    LogWarning "[$path] and target are the same path, skip linking"
    return
  fi

  if { [ -e "$target" ] || [ -L "$target" ]; } && { [ -e "$path" ] || [ -L "$path" ]; }; then
    resolved_target=$(readlink -f "$target" 2>/dev/null || printf '%s' "$target")
    resolved_path=$(readlink -f "$path" 2>/dev/null || printf '%s' "$path")
    if [ "$resolved_target" = "$resolved_path" ]; then
      LogWarning "[$path] already resolves to target, skip linking"
      return
    fi
  fi

  if [ -L "$path" ]; then
    rm -f "$path"
  elif [ -d "$path" ]; then
    rm -rf "$path"
  elif [ -e "$path" ]; then
    rm -f "$path"
  fi

  ln -s "$target" "$path" && echo 'Link ['"$target"'] => ['"$path"']'
}

CreateSymbolicLink() {
  local force=$1
  local target=$2
  local link_pos=$3
  local link_dir
  local resolved_link

  if [ "${link_pos: -1}" = "/" ]; then
    link_dir="$link_pos"
    resolved_link="${link_dir%/}/$(basename "$target")"
  else
    link_dir="${link_pos%/*}"
    resolved_link="$link_pos"
  fi

  # If link_pos has no slash (e.g. "my_link"), create it in current directory.
  if [ -z "$link_dir" ] || [ "$link_dir" = "$link_pos" -a "${link_pos#*/}" = "$link_pos" ]; then
    link_dir="."
  fi

  if [ ! -e "$link_dir" ]; then
    mkdir -p "$link_dir" 2> /dev/null
  fi

  if [ "$force" -eq "0" ]; then
    if [ -e "$resolved_link" ] || [ -L "$resolved_link" ]; then
      if [ -L "$resolved_link" ] && [ "$(readlink "$resolved_link")" = "$target" ]; then
        return
      fi

      ShowPathInfo "$resolved_link"
      if ConfirmOverwrite "$resolved_link"; then
        ReplaceWithSymlink "$target" "$resolved_link"
        return
      fi

      LogWarning "[$resolved_link] exists, skip linking"
      return
    fi
    ln -s "$target" "$resolved_link" && echo 'Link ['"$target"'] => ['"$resolved_link"']'
  else
      ReplaceWithSymlink "$target" "$resolved_link"
  fi
}
