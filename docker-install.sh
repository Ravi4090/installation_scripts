#!/bin/bash

###############################################################################
# Script Name : docker-install.sh
# Purpose     : Installs Docker Engine, Docker CLI, and related plugins on Ubuntu
# Author      : Ravi Shankar Rajupalepu
# Usage       : sudo ./docker-install.sh
# Supported OS: Ubuntu (with APT package manager)
###############################################################################

set -e  # Exit immediately if a command exits with a non-zero status

echo "Starting Docker installation..."

# Step 1: Update existing packages and install prerequisites
echo "Updating package index and installing prerequisites..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Step 2: Create keyrings directory for Docker's GPG key
echo "Creating keyring directory..."
sudo install -m 0755 -d /etc/apt/keyrings

# Step 3: Add Docker's official GPG key
echo "Adding Docker's official GPG key..."
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Step 4: Set up Docker repository
echo "Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Step 5: Update the package index again
echo "Updating package index with Docker repository..."
sudo apt-get update

# Step 6: Install Docker Engine and components
echo "Installing Docker Engine and related components..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Step 7: Start and enable Docker service
echo "Starting and enabling Docker service..."
sleep 10
sudo systemctl start docker
sudo systemctl enable docker

# Step 8: Confirm installation
echo "Docker installation completed successfully!"
docker --version

# Step 9: Docker Compose
echo "Docker Compose Install"
curl -SL https://github.com/docker/compose/releases/download/v2.36.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Step 10: Confirm installation
echo "Docker Compose installation completed successfully!"
docker-compose --version
