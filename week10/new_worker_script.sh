#!/bin/bash
LOCAL_IP=$(hostname -I | awk '{print $1}')
echo "K3s:425368a6d20251b41c21761ee78435e6" | sudo tee /tmp/my-token
#curl -sfL https://get.k3s.io | K3S_URL=https://10.0.1.108:6443 K3S_TOKEN=K3s:425368a6d20251b41c21761ee78435e6 sh -
MASTER_IP=10.0.1.108
curl -sfL https://get.k3s.io | K3S_URL=https://${MASTER_IP}:6443 K3S_TOKEN=$(cat /tmp/my-token) sh -