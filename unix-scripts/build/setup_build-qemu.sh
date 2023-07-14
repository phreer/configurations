#!/usr/bin/bash

BASE_DIR=$HOME/data/phree/qemu-virgl

# LIB_VIRGLRENDERER_PATH= $BASE_DIR/virglrenderer-install/
LIB_VIRGLRENDERER_PATH=$HOME/install/virglrenderer-dev/

export PKG_CONFIG_PATH=$LIB_VIRGLRENDERER_PATH/lib/x86_64-linux-gnu/pkgconfig
PREFIX=$BASE_DIR/qemu-install

../configure                   \
  --prefix=$PREFIX             \
  --target-list=x86_64-softmmu \
  --enable-kvm                 \
  --disable-werror             \
  --enable-opengl              \
  --enable-virglrenderer       \
  --enable-gtk                 \
  --enable-sdl
