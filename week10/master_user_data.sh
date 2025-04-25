#!/bin/bash
set -e  # Exit on error
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1  # Log output

echo "Starting user-data script"

# Update package list
sudo apt update -y
if [ $? -ne 0 ]; then
  echo "Failed to update package list"
  exit 1
fi

# Install prerequisites
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
if [ $? -ne 0 ]; then
  echo "Failed to install prerequisites"
  exit 1
fi

# Set up Docker's APT repository
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package list again
sudo apt update -y
if [ $? -ne 0 ]; then
  echo "Failed to update package list after adding Docker repo"
  exit 1
fi

# Install Docker
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
if [ $? -ne 0 ]; then
  echo "Failed to install Docker"
  exit 1
fi

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker.service

# Add ubuntu user to docker group
sudo usermod -a -G docker ubuntu

# Initialize Docker Swarm
sudo docker swarm init
if [ $? -ne 0 ]; then
  echo "Failed to initialize Docker Swarm"
  exit 1
fi

echo "user-data script completed successfully"