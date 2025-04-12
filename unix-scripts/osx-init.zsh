source $HOME/init.rc
source $HOME/osx-init.rc
source $HOME/init.zsh

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

  autoload -Uz compinit
  compinit
fi
