#!/usr/bin/env bash
set -euo pipefail

echo "Installing Node, pnpm, Codex, Bitwarden CLI, and MCP servers"

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

npm_global_bin="$(npm prefix -g)/bin"
npm install -g pnpm
for bin in pnpm pnpx; do
  if [ -x "${npm_global_bin}/${bin}" ]; then
    ln -sf "${npm_global_bin}/${bin}" "/usr/local/bin/${bin}"
  fi
done

PNPM_HOME=/usr/local /usr/local/bin/pnpm add -g \
  @bitwarden/cli \
  @playwright/mcp@0.0.78 \
  chrome-devtools-mcp@1.5.0

curl -fsSL https://chatgpt.com/codex/install.sh | sh

if [ -x /root/.local/bin/codex ]; then
  ln -sf /root/.local/bin/codex /usr/local/bin/codex
fi
