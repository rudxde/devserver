#!/usr/bin/env bash
set -euo pipefail

echo "Cleaning image"

apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
