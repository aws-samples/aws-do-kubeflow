#!/bin/bash

echo ""
echo "Installing kustomize ..."

#curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
curl -o kustomize -L https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v5.6.0/kustomize_v5.6.0_linux_amd64.tar.gz
tar -xzf kustomize
chmod +x kustomize
mv ./kustomize /usr/local/bin

kustomize version
