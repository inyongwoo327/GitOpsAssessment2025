#!/bin/bash
LOCAL_IP=$(hostname -I | awk '{print $1}')
curl -sfL https://get.k3s.io | sh -
sudo cat /var/lib/rancher/k3s/server/node-token
# Go through worker node install k3s manually