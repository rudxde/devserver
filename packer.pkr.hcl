packer {
  required_plugins {
    hcloud = {
      source  = "github.com/hetznercloud/hcloud"
      version = ">= 1.2.0"
    }
  }
}

locals {
  timestamp = formatdate("YYYYMMDDhhmmss", timestamp())
}

variable "base" {
  type    = string
  default = "debian-13"
}

variable "nvm_version" {
  type    = string
  default = "v0.40.5"
}

variable "node_version" {
  type    = string
  default = "lts/*"
}

variable "location" {
  type    = string
  default = "nbg1"
}

source "hcloud" "codeserver-arm64" {
  image         = var.base
  location      = var.location
  server_type   = "cax11"
  ssh_keys      = []
  user_data     = ""
  ssh_username  = "root"
  snapshot_name = "${var.base}-arm64-codeserver-${local.timestamp}"
  snapshot_labels = {
    architecture = "arm64"
    base         = var.base
    role         = "codeserver"
    timestamp    = local.timestamp
  }
}

source "hcloud" "codeserver-x86" {
  image         = var.base
  location      = var.location
  server_type   = "cpx22"
  ssh_keys      = []
  user_data     = ""
  ssh_username  = "root"
  snapshot_name = "${var.base}-x86-codeserver-${local.timestamp}"
  snapshot_labels = {
    architecture = "x86_64"
    base         = var.base
    role         = "codeserver"
    timestamp    = local.timestamp
  }
}

build {
  sources = [
    "source.hcloud.codeserver-arm64",
    "source.hcloud.codeserver-x86",
  ]

  provisioner "shell" {
    env = {
      DEBIAN_FRONTEND = "noninteractive"
      NODE_VERSION    = var.node_version
      NVM_VERSION     = var.nvm_version
    }
    scripts = [
      "scripts/00_prepare.sh",
      "scripts/01_docker.sh",
      "scripts/02_node_tools.sh",
      "scripts/03_k9s.sh",
      "scripts/04_iac_tools.sh",
      "scripts/99_cleanup.sh",
    ]
  }

  provisioner "file" {
    source      = "templates/sshd_config"
    destination = "/etc/ssh/sshd_config"
  }

  provisioner "file" {
    source      = "templates/prepare.sh"
    destination = "/root/prepare.sh"
  }

  provisioner "shell" {
    inline = [
      "mkdir -p /root/.ssh",
      "mkdir -p /root/.agents/skills/grill-me",
      "mkdir -p /root/.codex",
      "mkdir -p /root/.scripts",
      "mkdir -p /etc/profile.d",
    ]
  }

  provisioner "file" {
    source      = "templates/ssh/id_ed25519_michael.pub"
    destination = "/root/.ssh/authorized_keys"
  }

  provisioner "file" {
    source      = "templates/agents/skills/grill-me/SKILL.md"
    destination = "/root/.agents/skills/grill-me/SKILL.md"
  }

  provisioner "file" {
    source      = "templates/codex/AGENTS.md"
    destination = "/root/.codex/AGENTS.md"
  }

  provisioner "file" {
    source      = "templates/scripts/"
    destination = "/root/.scripts"
  }

  provisioner "file" {
    source      = "templates/gitconfig"
    destination = "/root/.gitconfig"
  }

  provisioner "file" {
    source      = "templates/profile.d/codeserver.sh"
    destination = "/etc/profile.d/codeserver.sh"
  }

  provisioner "shell" {
    inline = [
      "chmod 700 /root/prepare.sh",
      "chmod 700 /root/.ssh",
      "chmod 600 /root/.ssh/authorized_keys",
      "chmod 600 /root/.agents/skills/grill-me/SKILL.md",
      "chmod 600 /root/.codex/AGENTS.md",
      "chmod 700 /root/.scripts",
      "chmod 755 /root/.scripts/index.sh /root/.scripts/terraform.sh",
      "chmod 644 /root/.scripts/git-aliases.sh /root/.scripts/kustomize.sh",
      "chmod 600 /root/.gitconfig",
      "chmod 644 /etc/profile.d/codeserver.sh",
      "grep -qxF '[ -f /root/.scripts/index.sh ] && . /root/.scripts/index.sh' /root/.bashrc || printf '\\n[ -f /root/.scripts/index.sh ] && . /root/.scripts/index.sh\\n' >> /root/.bashrc",
    ]
  }
}
