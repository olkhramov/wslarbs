#!/bin/bash

# Variables
PROGRAMS_CSV="programs.csv"
CA_CERTS_DIR="ca-certificates"

# Detect distribution
if grep -qi ubuntu /etc/os-release; then
    DISTRO="ubuntu"
    PKG_MANAGER="apt"
    PKG_UPDATE="apt update && apt upgrade -y"
    PKG_INSTALL="apt install -y"
elif grep -qi fedora /etc/os-release; then
    DISTRO="fedora"
    PKG_MANAGER="dnf"
    PKG_UPDATE="dnf update -y"
    PKG_INSTALL="dnf install -y"
else
    echo "Unsupported distribution. Exiting."
    exit 1
fi

# Update and Upgrade
echo "Updating and upgrading packages..."
sudo $PKG_UPDATE

# Install programs from CSV
if [ -f "$PROGRAMS_CSV" ]; then
    while IFS= read -r program; do
        echo "Installing: $program"
        sudo $PKG_INSTALL "$program"
    done < "$PROGRAMS_CSV"
else
    echo "$PROGRAMS_CSV does not exist. Skipping program installations from CSV."
fi

# Function to install Podman
install_podman() {
    echo "Installing Podman..."
    if [ "$DISTRO" == "ubuntu" ]; then
        sudo $PKG_INSTALL apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_$(lsb_release -rs)/Release.key | sudo gpg --dearmor -o /usr/share/keyrings/devel_kubic_libcontainers_stable.gpg
        echo "deb [signed-by=/usr/share/keyrings/devel_kubic_libcontainers_stable.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_$(lsb_release -rs)/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list > /dev/null
        sudo $PKG_UPDATE
        sudo $PKG_INSTALL podman
    elif [ "$DISTRO" == "fedora" ]; then
        sudo dnf -y install dnf-plugins-core
        sudo dnf config-manager --add-repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Fedora_$(rpm -E %fedora)/devel:kubic:libcontainers:stable.repo
        sudo dnf install -y podman
    fi
}

# Function to install terraform

install_terraform() {
    echo "Installing Terraform..."
    if [ "$DISTRO" == "ubuntu" ]; then
        sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
        wget -O- https://apt.releases.hashicorp.com/gpg | \
        gpg --dearmor | \
        sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
            https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
            sudo tee /etc/apt/sources.list.d/hashicorp.list

        sudo apt update
        sudo apt-get install terraform
    elif [ "$DISTRO" == "fedora" ]; then
        sudo dnf install -y dnf-plugins-core
        sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
        sudo dnf -y install terraform
    fi
}

# Install Docker
install_docker

install_terraform

# Import CA Certificates
if [ -d "$CA_CERTS_DIR" ] && [ "$(ls -A $CA_CERTS_DIR)" ]; then
    echo "Importing CA certificates..."
    for cert in $CA_CERTS_DIR/*; do
        sudo cp "$cert" /usr/local/share/ca-certificates/ 2>/dev/null || sudo cp "$cert" /etc/pki/ca-trust/source/anchors/ 2>/dev/null
    done
    if [ "$DISTRO" == "ubuntu" ]; then
        sudo update-ca-certificates
    elif [ "$DISTRO" == "fedora" ]; then
        sudo update-ca-trust
    fi
else
    echo "No CA certificates directory found, or it's empty. Skipping CA imports."
fi

echo "Setup complete. You may need to log out and back in for some changes to take effect."
