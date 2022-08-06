#!/bin/bash

if [ -f ../../../../../.env ]; then
        pushd ../../../../../
        source .env
        popd
fi

git clone https://github.com/awslabs/kubeflow-manifests.git

pushd kubeflow-manifests

git checkout ${AWS_RELEASE_VERSION}

git clone --branch ${KUBEFLOW_RELEASE_VERSION} https://github.com/kubeflow/manifests.git upstream
export REPO_ROOT=$(pwd)

echo ""
echo "Deleting Kubeflow user profiles ..."

kubectl get profile
kubectl delete profile --all

echo ""
echo "Deleting Kubeflow deployment ..."

pushd $REPO_ROOT

kustomize build deployments/vanilla/ | kubectl delete -f -

#kustomize build deployments/rds-s3 | kubectl delete -f -

kubectl delete mutatingwebhookconfigurations.admissionregistration.k8s.io webhook.eventing.knative.dev webhook.istio.networking.internal.knative.dev webhook.serving.knative.dev
kubectl delete validatingwebhookconfigurations.admissionregistration.k8s.io config.webhook.eventing.knative.dev config.webhook.istio.networking.internal.knative.dev config.webhook.serving.knative.dev
kubectl delete endpoints -n default mxnet-operator pytorch-operator tf-operator

#pushd tests/e2e
#pip install -r requirements.txt
#PYTHONPATH=.. python3 utils/rds-s3/auto-rds-s3-cleanup.py
#popd

popd
popd

