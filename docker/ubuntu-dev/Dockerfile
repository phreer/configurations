FROM ubuntu:24.04

ARG USERNAME=liuweife
ARG UID=1000
ARG GID=1000

RUN groupmod -g ${GID} -n ${USERNAME} ubuntu \
    && usermod -u ${UID} -l ${USERNAME} -d /home/${USERNAME} -m -g ${USERNAME} ubuntu

RUN apt-get update
RUN yes | unminimize
RUN apt-get install -y \
  sudo \
  build-essential \
  cmake \
  git \
  curl \
  wget \
  unzip \
  man \
  tmux \
  bash-completion \
  kitty-terminfo \
  zsh \
  fzf \
  vim \
  python3-dev \
  python3-pip

USER ${USERNAME}
WORKDIR /home/${USERNAME}
ENV HOME=/home/${USERNAME}
