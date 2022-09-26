#!/bin/sh

if [ -d /etc/apt ]; then
        [ -n "$http_proxy" ] && echo "Acquire::http::proxy \"${http_proxy}\";" > /etc/apt/apt.conf; \
        [ -n "$https_proxy" ] && echo "Acquire::https::proxy \"${https_proxy}\";" >> /etc/apt/apt.conf; \
        [ -f /etc/apt/apt.conf ] && cat /etc/apt/apt.conf
fi

apt-get update
apt-get install -y sudo python3-dev libpq-dev htop openssl

echo "alias ll='ls -alh --color=auto'" >> /etc/bash.bashrc
echo "alias k=kubectl" >> /etc/bash.bashrc

echo "echo ''; cat /startup/workbench.txt; echo ''" >> /etc/bash.bashrc

usermod -a -G sudo jovyan
usermod -p \$6\$KjQB0ECcOc3RZu4U\$gUuNRUPpM21qkDzUEu9jYh.ghGccTjaRQoa/Fms17xLsDGfW2X6y8kcS7XooQDhhjBpxNYMcCN4QoxCp0MDYo1 jovyan

if [ "${PASSWD}" != "" ]; then
    echo ""
    echo "Setting password for jovyan from environment ..."
    echo "${PASSWD}\n${PASSWD}" | passwd jovyan
fi

# Install kubectl
curl -Lo kubectl https://dl.k8s.io/release/v1.24.0/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin
kubectl version --client

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf ./aws
rm -f awscliv2.zip
