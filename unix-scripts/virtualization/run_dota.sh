#!/usr/bin/bash

# DRI_DRIVER_PATH=/usr/lib/i386-linux-gnu
DRI_DRIVER_PATH=$HOME/install/mesa-22.3.0-i386/lib
export LIBGL_DRIVERS_PATH=$DRI_DRIVER_PATH/dri
export LD_LIBRARY_PATH=$DRI_DRIVER_PATH

"$HOME/.steam/steam/steamapps/common/dota 2 beta/game/dota.sh" -gl $@
