#!/bin/bash

sudo --preserve-env=http_proxy,https_proxy \
  dnf install \
  fd \
  git \
  ripgrep \
  tmux \
  uv \
  vim \

