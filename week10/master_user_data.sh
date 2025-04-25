#!/bin/bash
set -e  # Exit on error
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1  # Log output

echo "Starting K3s master node user-data script"

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