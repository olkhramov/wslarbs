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

# Function to install Docker
install_docker() {
    echo "Installing Docker..."
    if [ "$DISTRO" == "ubuntu" ]; then
        sudo $PKG_INSTALL apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        sudo $PKG_UPDATE
        sudo $PKG_INSTALL docker-ce docker-ce-cli containerd.io
    elif [ "$DISTRO" == "fedora" ]; then
        sudo dnf -y install dnf-plugins-core
        sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
        sudo dnf install -y docker-ce docker-ce-cli containerd.io
    fi
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER
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
