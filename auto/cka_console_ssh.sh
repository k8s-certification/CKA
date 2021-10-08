#!/bin/bash 
curl -LO https://dl.k8s.io/release/v1.21.0/bin/linux/amd64/kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
sudo snap install yq

su - ubuntu -c  "ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa <<< y 2>&1 >/dev/null"

su - ubuntu -c "cd ~/.ssh; python3 -m http.server"