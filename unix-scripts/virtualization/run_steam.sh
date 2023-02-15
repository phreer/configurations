#!/usr/bin/bash

DRI_PRIME=pci-0000_00_02_0
DRI_DRIVER_PATH=/usr/lib/i386-linux-gnu
# DRI_DRIVER_PATH=~/install/mesa-22.3.0-i386/lib
export LIBGL_DRIVERS_PATH=$DRI_DRIVER_PATH/dri
export LD_LIBRARY_PATH=$DRI_DRIVER_PATH

steam $@
