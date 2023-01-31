#!/bin/sh
set -eu

# Configuration -- adjust these to your liking
PINENTRY_TERMINAL='/usr/bin/pinentry-curses'
PINENTRY_X11='/usr/bin/pinentry-x11'

# Action happens below!
if [ -n "${DISPLAY-}" -a -z "${TERM-}" ]; then
    exec "$PINENTRY_X11" "$@"
else
    exec "$PINENTRY_TERMINAL" "$@"
fi
