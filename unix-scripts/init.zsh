ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)

# Make key binding of M-Backspace consistent with bash, namely delete backward
# until white space or splash.
autoload -U select-word-style
select-word-style bash

# Initialize command prompt
export PS1="%F{blue}%n@%m%f:%F{green}%~%f%# "

bindkey -s '\eo' 'cd ..\n'
