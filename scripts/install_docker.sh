#!/bin/bash

# Uninstall old versions
sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc docker-buildx podman-docker containerd runc | cut -f1)

# Set up Docker's apt repository
## Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

## Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

# Install the Docker packages
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo -e "\033[1;33mFor instructions on installing the NVIDIA Container Toolkit, see
    https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html\033[0m"

echo -e "\033[1;33mFor instructions on enabling Rootless mode, see
    https://docs.docker.com/engine/security/rootless/\033[0m"

echo -e "\033[1;33mTo install DevPod for using devcontainers, run
    curl -L -o devpod \"https://github.com/loft-sh/devpod/releases/latest/download/devpod-linux-amd64\" \\
    && sudo install -c -m 0755 devpod /usr/local/bin \\
    && rm -f devpod\033[0m"
