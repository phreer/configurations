source "$(dirname "$0")/log_utils.sh"

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
        if [ -d "$resolved_link" ] && [ ! -L "$resolved_link" ]; then
          rm -rf "$resolved_link"
        fi
        ln -sf "$target" "$resolved_link" && echo 'Link ['"$target"'] => ['"$resolved_link"']'
        return
      fi

      LogWarning "[$resolved_link] exists, skip linking"
      return
    fi
    ln -s "$target" "$resolved_link" && echo 'Link ['"$target"'] => ['"$resolved_link"']'
  else
    if [ -d "$resolved_link" ] && [ ! -L "$resolved_link" ]; then
      rm -rf "$resolved_link"
    fi
    ln -sf "$target" "$resolved_link" && echo 'Link ['"$target"'] => ['"$resolved_link"']'
  fi
}
