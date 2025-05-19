#!/bin/bash
set -e

echo "Uninstalling WordPress..."
export KUBECONFIG=$(pwd)/kubeconfig
helm uninstall wordpress -n wordpress || true

echo "Running terraform destroy..."
terraform destroy