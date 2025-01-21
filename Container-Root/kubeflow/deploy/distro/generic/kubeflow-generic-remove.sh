#!/bin/bash

if [ -f ../../../../../.env ]; then
        pushd ../../../../../
        source .env
        popd
fi

pushd ${KF_DIR}/manifests

kustomize build example > resources.yaml

kubectl delete -f resources.yaml

popd
