source $HOME/init.rc
source $HOME/linux-init.rc
source $HOME/init.zsh

# Initialize command prompt
export PS1="%n@%m:%~%# "

bindkey -s '\eo' 'cd ..\n'
