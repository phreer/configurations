source $HOME/linux-init-common.sh

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)

# Initialize command prompt
export PS1="%n@%m:%~%# "

bindkey -s '\eo' 'cd ..\n'
