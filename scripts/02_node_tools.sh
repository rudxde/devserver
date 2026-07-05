#!/usr/bin/env bash
set -euo pipefail

echo "Installing Node, pnpm, Codex, and Bitwarden CLI"

: "${NVM_VERSION:?NVM_VERSION is required}"
: "${NODE_VERSION:?NODE_VERSION is required}"

export NVM_DIR="/usr/local/nvm"

install -m 0755 -d "$NVM_DIR"
curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" -o /tmp/install_nvm.sh
PROFILE=/dev/null bash /tmp/install_nvm.sh

# shellcheck source=/dev/null
. "$NVM_DIR/nvm.sh"

nvm install "$NODE_VERSION"
installed_node="$(nvm version "$NODE_VERSION")"
nvm alias default "$installed_node"
nvm use default

cat >/etc/profile.d/nvm.sh <<'EOF'
export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
EOF
chmod 0644 /etc/profile.d/nvm.sh

node_bin="$(dirname "$(nvm which default)")"
for bin in node npm npx corepack; do
  ln -sf "${node_bin}/${bin}" "/usr/local/bin/${bin}"
done

npm install -g \
  @bitwarden/cli \
  @openai/codex \
  pnpm

npm_global_bin="$(npm prefix -g)/bin"
for bin in bw codex pnpm pnpx; do
  if [ -x "${npm_global_bin}/${bin}" ]; then
    ln -sf "${npm_global_bin}/${bin}" "/usr/local/bin/${bin}"
  fi
done
