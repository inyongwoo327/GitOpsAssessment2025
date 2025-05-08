#!/bin/bash
LOCAL_IP=$(hostname -I | awk '{print $1}')
curl -sfL https://get.k3s.io | sudo sh -s - server   --node-ip=${LOCAL_IP}   --cluster-init   --disable=traefik   --disable=servicelb   --write-kubeconfig-mode 644   --token-file  /tmp/my-token  --bind-address=${LOCAL_IP}   --advertise-address=${LOCAL_IP}
sudo cat /var/lib/rancher/k3s/server/node-token
