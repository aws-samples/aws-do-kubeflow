#!/bin/bash

echo ""
echo "Installing kustomize ..."

#curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
curl -o kustomize -L https://github.com/kubernetes-sigs/kustomize/releases/download/v3.2.0/kustomize_3.2.0_linux_amd64
chmod +x kustomize
mv ./kustomize /usr/local/bin

kustomize version
