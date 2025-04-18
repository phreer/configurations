ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)

load_antigen_bundles() {
  antigen bundle zsh-users/zsh-completions
  antigen bundle zsh-users/zsh-syntax-highlighting
  antigen bundle command-not-found

  antigen apply
}

# Make key binding of M-Backspace consistent with bash, namely delete backward
# until white space or splash.
autoload -U select-word-style
select-word-style bash

# Initialize command prompt
export PS1="%F{blue}%n@%m%f:%F{green}%~%f%# "

bindkey -s '\eo' 'cd ..\n'
bindkey -e

# Command history
HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
# Share history among sessions
setopt SHARE_HISTORY

# antigen for plugin management
if [ -e $HOME/antigen.zsh ]; then
  source $HOME/antigen.zsh
  load_antigen_bundles
fi
