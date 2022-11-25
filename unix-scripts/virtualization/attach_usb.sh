#!/usr/bin/sh

WORKSPACE_DIR="$HOME"/workspace
CROSVM_DIR="$WORKSPACE_DIR"/crosvm
sudo chown -R phree  /dev/bus/usb/001

"$CROSVM_DIR"/target/debug/crosvm usb attach 1:1:1:4 /dev/bus/usb/001/004 "$CROSVM_DIR"/crosvm.sock
"$CROSVM_DIR"/target/debug/crosvm usb attach 1:1:1:5 /dev/bus/usb/001/005 "$CROSVM_DIR"/crosvm.sock
