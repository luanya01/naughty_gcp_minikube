#!/bin/bash
apt-get update -y && apt-get install -y curl conntrack git
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
chmod 666 /var/run/docker.sock
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube