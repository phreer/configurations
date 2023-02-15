#!/usr/bin/bash
# sudo chown -R phree /dev/dri

export MESA_DEBUG=1
export MESA_LOG_LEVEL=debug
export LIBGL_DEBUG=verbose

DRIVERS_PATH=/usr/lib/x86_64-linux-gnu
# DRIVERS_PATH=$HOME/local/lib/x86_64-linux-gnu
# export LD_LIBRARY_PATH=$HOME/local/lib:$HOME/local/lib/x86_64-linux-gnu:$HOME/local/lib/x86_64-linux-gnu/dri
export LD_LIBRARY_PATH=$DRIVERS_PATH:$LD_LIBRARY_PATH
export LIBGL_DRIVERS_PATH=$DRIVERS_PATH/dri
# export DRI_PRIME=pci-0000_00_02_0
# export MESA_LOADER_DRIVER_OVERRIDE=iris

sommelier \
  --xwayland-path=$(which Xwayland) \
  --xwayland-gl-driver-path=$LIBGL_DRIVERS_PATH \
  --virtgpu-channel -X --x-display=:0 --glamor \
  $@

