source $HOME/init.rc
source $HOME/osx-init.rc
source $HOME/init.zsh

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  fpath=( "$(brew --prefix)/share/zsh/site-functions" $fpath )

  autoload -Uz compinit
  compinit
fi

if [ -e /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
