#!/bin/bash

export PKG_CONFIG_PATH=$HOME/install/wayland-dev/lib/x86_64-linux-gnu/pkgconfig/

meson setup ./builddir -Dprefix=$HOME/install/wlroots-dev \
  -Dpkg_config_path=$PKG_CONFIG_PATH \
  $@
