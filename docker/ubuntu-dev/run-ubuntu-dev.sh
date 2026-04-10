#!/bin/bash

docker run -dit \
  --name ubuntu-dev \
  --hostname ubuntu-dev \
  -w "/home/$(id -un)" \
  -e HOME="/home/$(id -un)" \
  -v "$HOME:/home/$(id -un):z" \
  --cap-add=SYS_ADMIN \
  --security-opt apparmor=unconfined \
  --security-opt seccomp=unconfined \
  ubuntu-dev \
  bash
