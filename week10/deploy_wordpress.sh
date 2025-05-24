#!/bin/bash
set -e

echo "Starting WordPress deployment orchestration on master node..."

# Make sure we're in the home directory
cd ~

# Execute the WordPress deployment script
echo "Executing WordPress deployment..."
if [ -f "./wordpress_deployment_remote.sh" ]; then
    chmod +x ./wordpress_deployment_remote.sh
    ./wordpress_deployment_remote.sh
else
    echo "Error: wordpress_deployment_remote.sh not found!"
    exit 1
fi

echo "WordPress deployment orchestration completed!"