#!/bin/bash

docker run -it --name arch-builder \
  -v $HOME/workspace/surface/linux-surface/linux-surface:/opt/linux-surface \
  -v $HOME/configurations/:/opt/configurations \
  archlinux bash
