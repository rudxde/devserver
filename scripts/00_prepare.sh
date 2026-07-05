#!/usr/bin/env bash
set -euo pipefail

echo "Preparing system"

apt-get update
apt-get upgrade -y
apt-get install -y \
  build-essential \
  apt-transport-https \
  ca-certificates \
  curl \
  git \
  gnupg \
  groff \
  jq \
  less \
  tar \
  tmux \
  unzip \
  xz-utils

install -m 0755 -d /etc/apt/keyrings
