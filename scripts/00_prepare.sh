#!/usr/bin/env bash
set -euo pipefail

echo "Preparing system"

apt-get update
apt-get upgrade -y
apt-get install -y \
  build-essential \
  bubblewrap \
  apt-transport-https \
  ca-certificates \
  chromium \
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
