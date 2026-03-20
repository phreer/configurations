# Common Bash prompt with SHELL_TAG support and fish-style collapsed path.
PS1='${SHELL_TAG:+[\[\033[01;33m\]${SHELL_TAG}\[\033[00m\]] }${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]$(_fish_collapsed_pwd)\[\033[00m\]\$ '
