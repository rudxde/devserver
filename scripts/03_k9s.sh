#!/usr/bin/env bash
set -euo pipefail

echo "Installing k9s"

case "$(dpkg --print-architecture)" in
  amd64)
    k9s_arch="amd64"
    ;;
  arm64)
    k9s_arch="arm64"
    ;;
  *)
    echo "Unsupported architecture: $(dpkg --print-architecture)" >&2
    exit 1
    ;;
esac

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

curl -fsSL "https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_${k9s_arch}.tar.gz" -o "${tmp_dir}/k9s.tar.gz"
tar -xzf "${tmp_dir}/k9s.tar.gz" -C "$tmp_dir" k9s
install -m 0755 "${tmp_dir}/k9s" /usr/local/bin/k9s
