source $HOME/init.rc
source $HOME/linux-init.rc
source $HOME/init.sh

PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]$(_fish_collapsed_pwd)\[\033[00m\]\$ '

# Setup X server display for WSL.
# But this should be unnecessary with WSLg support.
if is_wsl; then
    export DISPLAY=$(awk '/nameserver / {print $2; exit}' /etc/resolv.conf 2>/dev/null):0
    export LIBGL_ALWAYS_INDIRECT=1
fi
# export TERM=screen-256color
