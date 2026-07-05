# Codeserver Image

Build Hetzner Cloud snapshots for a codeserver VM.

## Tools

- git
- tmux
- Docker Engine + compose plugin
- Terraform
- Packer
- AWS CLI
- Helm
- kubectl
- Node/npm via nvm
- pnpm
- Codex CLI
- Bitwarden CLI
- k9s
- grill-me agent skill, copied to `/root/.agents/skills/grill-me/SKILL.md`
- Codex instructions, copied to `/root/.codex/AGENTS.md`
- shell helper scripts, copied to `/root/.scripts`
- SSH public key, copied to `/root/.ssh/authorized_keys`
- git identity, copied to `/root/.gitconfig`

## Build

```bash
export HCLOUD_TOKEN="<TOKEN>"
packer init .
packer validate .
packer build .
```

## Runtime prep

Run on the VM as root:

```bash
/root/prepare.sh
```

It logs in to Bitwarden interactively, reads:

- `codeserver_ssh_key`
- `codeserver_docker_hub_token`

Then writes `/root/.ssh/id_ed25519` and runs `docker login`.
Bitwarden session/app data lives in a temp dir and is removed on exit.
