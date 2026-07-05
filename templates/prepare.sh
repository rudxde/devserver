#!/usr/bin/env bash
set -euo pipefail

SSH_KEY_ITEM="codeserver_ssh_key"
DOCKER_HUB_ITEM="codeserver_docker_hub_token"

umask 077

bw_tmp_dir="$(mktemp -d)"
export BITWARDENCLI_APPDATA_DIR="$bw_tmp_dir"
BW_SESSION=""
export BW_SESSION

cleanup() {
  rc="$?"
  set +e
  if [ -n "${BW_SESSION:-}" ]; then
    bw lock >/dev/null 2>&1
  fi
  bw logout >/dev/null 2>&1
  unset BW_SESSION
  rm -rf "$bw_tmp_dir"
  exit "$rc"
}
trap cleanup EXIT INT TERM

require_value() {
  name="$1"
  value="$2"
  if [ -z "$value" ] || [ "$value" = "null" ]; then
    echo "Missing ${name}" >&2
    exit 1
  fi
}

echo "Log in to Bitwarden"
BW_SESSION="$(bw login --raw)"
export BW_SESSION

bw sync >/dev/null

ssh_item_json="$(bw get item "$SSH_KEY_ITEM")"
private_key="$(
  printf '%s' "$ssh_item_json" |
    jq -r '(.sshKey.privateKey // (.fields[]? | select(.name == "privateKey" or .name == "private_key" or .name == "ssh_private_key") | .value) // empty)'
)"
require_value "$SSH_KEY_ITEM private key" "$private_key"

install -m 0700 -d /root/.ssh
printf '%s\n' "$private_key" >/root/.ssh/id_ed25519
chmod 0600 /root/.ssh/id_ed25519

docker_item_json="$(bw get item "$DOCKER_HUB_ITEM")"
docker_username="$(printf '%s' "$docker_item_json" | jq -r '.login.username // empty')"
docker_token="$(printf '%s' "$docker_item_json" | jq -r '.login.password // empty')"
require_value "$DOCKER_HUB_ITEM username" "$docker_username"
require_value "$DOCKER_HUB_ITEM token" "$docker_token"

printf '%s' "$docker_token" | docker login --username "$docker_username" --password-stdin

echo "Prepared /root/.ssh/id_ed25519 and Docker Hub login"
