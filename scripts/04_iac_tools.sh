#!/usr/bin/env bash
set -euo pipefail

echo "Installing Terraform, Packer, Helm, kubectl, and AWS CLI"

. /etc/os-release

HELM_BUILDKITE_APT_KEY_ID="DDF78C3E6EBB2D2CC223C95C62BA89D07698DBC6"
KUBERNETES_VERSION="v1.36"

curl -fsSL https://apt.releases.hashicorp.com/gpg -o /tmp/hashicorp.asc
gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg /tmp/hashicorp.asc
chmod a+r /usr/share/keyrings/hashicorp-archive-keyring.gpg

curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey -o /tmp/helm.gpg
helm_key_id="$(gpg --show-keys --with-colons /tmp/helm.gpg | awk -F: '$1 == "fpr" {print $10}' | head -n 1)"
if [ "$helm_key_id" != "$HELM_BUILDKITE_APT_KEY_ID" ]; then
  echo "Unexpected Helm APT key ID: $helm_key_id" >&2
  exit 1
fi
gpg --dearmor -o /usr/share/keyrings/helm.gpg /tmp/helm.gpg
chmod a+r /usr/share/keyrings/helm.gpg

curl -fsSL "https://pkgs.k8s.io/core:/stable:/${KUBERNETES_VERSION}/deb/Release.key" -o /tmp/kubernetes.asc
gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg /tmp/kubernetes.asc
chmod a+r /etc/apt/keyrings/kubernetes-apt-keyring.gpg

arch="$(dpkg --print-architecture)"
cat >/etc/apt/sources.list.d/hashicorp.list <<EOF
deb [arch=${arch} signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com ${VERSION_CODENAME} main
EOF
cat >/etc/apt/sources.list.d/helm-stable-debian.list <<EOF
deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main
EOF
cat >/etc/apt/sources.list.d/kubernetes.list <<EOF
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${KUBERNETES_VERSION}/deb/ /
EOF

apt-get update
apt-get install -y \
  helm \
  kubectl \
  packer \
  terraform

case "$arch" in
  amd64)
    aws_arch="x86_64"
    ;;
  arm64)
    aws_arch="aarch64"
    ;;
  *)
    echo "Unsupported architecture: $arch" >&2
    exit 1
    ;;
esac

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${aws_arch}.zip" -o "${tmp_dir}/awscliv2.zip"
unzip -q "${tmp_dir}/awscliv2.zip" -d "$tmp_dir"
"${tmp_dir}/aws/install" --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
