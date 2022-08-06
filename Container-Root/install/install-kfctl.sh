#!/bin/bash

# install kfctl
curl --silent --location "https://github.com/kubeflow/kfctl/releases/download/v1.0.1/kfctl_v1.0.1-0-gf3edb9b_linux.tar.gz" | tar xz -C /tmp
mv -v /tmp/kfctl /usr/local/bin

