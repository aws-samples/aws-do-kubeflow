#!/bin/sh

# configure proxy
if [ -d /etc/apt ]; then
        [ -n "$http_proxy" ] && echo "Acquire::http::proxy \"${http_proxy}\";" > /etc/apt/apt.conf; \
        [ -n "$https_proxy" ] && echo "Acquire::https::proxy \"${https_proxy}\";" >> /etc/apt/apt.conf; \
        [ -f /etc/apt/apt.conf ] && cat /etc/apt/apt.conf
fi

# install tools
apt-get update && apt-get install -y curl wget jq vim git watch python3-distutils python3-apt python3-pip 

# Install utilities
#./install/install-python.sh
./install/install-authenticator.sh
./install/install-kubectl.sh
./install/install-kubectx.sh
./install/install-kubetail.sh
./install/install-kubeshell.sh
./install/install-kubeps1.sh
./install/install-yq.sh
./install/install-kustomize.sh
./install/install-docker.sh
./install/install-eksctl.sh
./install/install-kfctl.sh
./install/install-helm.sh

# install aws cli
pip3 install awscli --upgrade

# enable python debugging
pip3 install debugpy kubernetes kubeflow-training

