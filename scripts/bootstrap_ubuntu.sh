#!/bin/bash

set -euo pipefail

# Dependencies
sudo apt-get update -qq
sudo apt-get install -y \
    build-essential \
    curl \
    wget \
    git \
    vim \
    tree \
    jq \
    fcitx5 \
    fcitx5-mozc \
    fcitx5-configtool

# gh
(type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
    && sudo mkdir -p -m 755 /etc/apt/keyrings \
    && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && sudo mkdir -p -m 755 /etc/apt/sources.list.d \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt update \
    && sudo apt install gh -y

# uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Pixi
curl -fsSL https://pixi.sh/install.sh | sh

# Miniforge
curl -L "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh" -o "/tmp/Miniforge3-$(uname)-$(uname -m).sh"
bash "/tmp/Miniforge3-$(uname)-$(uname -m).sh" -b

# ripgrep
RG_VER=$(curl -fsSL https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | jq -r .tag_name)
RG_DIR="ripgrep-${RG_VER}-$(uname -m)-unknown-linux-musl"
RG_PREFIX="$HOME/.local/share/ripgrep/versions/v${RG_VER}"
curl -fsSL -o "/tmp/${RG_DIR}.tar.gz" "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VER}/${RG_DIR}.tar.gz"
curl -fsSL -o "/tmp/${RG_DIR}.tar.gz.sha256" "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VER}/${RG_DIR}.tar.gz.sha256"
(cd /tmp && sha256sum -c "${RG_DIR}.tar.gz.sha256")
rm -rf "$RG_PREFIX"
mkdir -p "$RG_PREFIX" ~/.local/bin ~/.local/share/man/man1 ~/.local/share/bash-completion/completions
tar xzf "/tmp/${RG_DIR}.tar.gz" -C "$RG_PREFIX" --strip-components=1
ln -sf "$RG_PREFIX/rg" ~/.local/bin/rg
ln -sf "$RG_PREFIX/doc/rg.1" ~/.local/share/man/man1/rg.1
ln -sf "$RG_PREFIX/complete/rg.bash" ~/.local/share/bash-completion/completions/rg

# Neovim
NVIM_VER=$(curl -fsSL https://api.github.com/repos/neovim/neovim/releases/latest | jq -r .tag_name)
NVIM_PREFIX="$HOME/.local/share/nvim/versions/${NVIM_VER}"
curl -fsSL -o /tmp/nvim-linux-x86_64.tar.gz "https://github.com/neovim/neovim/releases/download/${NVIM_VER}/nvim-linux-x86_64.tar.gz"
rm -rf "$NVIM_PREFIX"
mkdir -p "$NVIM_PREFIX" ~/.local/bin
tar xzf /tmp/nvim-linux-x86_64.tar.gz -C "$NVIM_PREFIX" --strip-components=1
ln -sf "$NVIM_PREFIX/bin/nvim" ~/.local/bin/nvim

# Zellij
ZELLIJ_VER=$(curl -fsSL https://api.github.com/repos/zellij-org/zellij/releases/latest | jq -r .tag_name)
ZELLIJ_PREFIX="$HOME/.local/share/zellij/versions/${ZELLIJ_VER}"
ZELLIJ_URL="https://github.com/zellij-org/zellij/releases/download/${ZELLIJ_VER}/zellij-x86_64-unknown-linux-musl"
mkdir -p /tmp/zellij-dl
curl -fsSL -o /tmp/zellij-dl/zellij.tar.gz "${ZELLIJ_URL}.tar.gz"
curl -fsSL -o /tmp/zellij-dl/zellij.sha256sum "${ZELLIJ_URL}.sha256sum"
rm -rf "$ZELLIJ_PREFIX"
mkdir -p "$ZELLIJ_PREFIX" ~/.local/bin ~/.local/share/bash-completion/completions
tar xzf /tmp/zellij-dl/zellij.tar.gz -C "$ZELLIJ_PREFIX"
sed "s|target/.*/release/|${ZELLIJ_PREFIX}/|" /tmp/zellij-dl/zellij.sha256sum | sha256sum -c
"$ZELLIJ_PREFIX/zellij" setup --generate-completion bash > "$ZELLIJ_PREFIX/zellij.bash"
ln -sf "$ZELLIJ_PREFIX/zellij" ~/.local/bin/zellij
ln -sf "$ZELLIJ_PREFIX/zellij.bash" ~/.local/share/bash-completion/completions/zellij

# Dotfiles
source "$(dirname "${BASH_SOURCE[0]}")/lib/link.sh"

# "<path in this repo>:<path relative to $HOME>"
LINKS=(
  "bash/bashrc:.bashrc"
  "bash/bash_aliases:.bash_aliases"
  "neovim/config:.config/nvim"
  "niri/config:.config/niri"
)

for link in "${LINKS[@]}"; do
    link_file "${link%%:*}" "${link#*:}"
done

echo "Dotfiles installation complete!"
