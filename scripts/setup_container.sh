#!/usr/bin/env bash

set -euo pipefail

# Dependencies
if command -v apt-get &> /dev/null; then
  sudo apt-get update -qq
  sudo apt-get install --no-install-recommends -y \
    ca-certificates \
    build-essential \
    curl \
    wget \
    git \
    tree \
    jq
fi

# Rust & Cargo
curl https://sh.rustup.rs -sSf | sh -s -- -y

# Pixi
curl -fsSL https://pixi.sh/install.sh | sh

export PATH="$HOME/.pixi/bin:$PATH"
pixi global install \
  gh \
  git-lfs \
  ipython \
  nvim \
  ripgrep \
  ruff \
  uv \
  zellij

# Dotfiles
source "$(dirname "${BASH_SOURCE[0]}")/lib/link.sh"

# "<path in this repo>:<path relative to $HOME>"
LINKS=(
  "bash/bashrc:.bashrc"
  "bash/bash_aliases:.bash_aliases"
  "neovim/config:.config/nvim"
)

for link in "${LINKS[@]}"; do
    link_file "${link%%:*}" "${link#*:}"
done

echo "Dotfiles installation complete!"
