source $__INIT_DIR/init.rc
source $__INIT_DIR/linux-init.rc
source $__INIT_DIR/init.sh

# Setup X server display for WSL.
# But this should be unnecessary with WSLg support.
if is_wsl; then
    export DISPLAY=$(awk '/nameserver / {print $2; exit}' /etc/resolv.conf 2>/dev/null):0
    export LIBGL_ALWAYS_INDIRECT=1
fi
# export TERM=screen-256color
