source $HOME/linux-init-common.sh

# Initialize command prompt
export PS1="%n@%m:%~%# "

bindkey -s '\eo' 'cd ..\n'
