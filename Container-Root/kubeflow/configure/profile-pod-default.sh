#!/bin/bash


if [ "$1" == "" ]; then
	export NS=kubeflow-user-example-com
	echo "Argument not provided, assuming default user namespace $NS ..."
else
	export NS=$1
fi

printf "
apiVersion: kubeflow.org/v1alpha1
kind: PodDefault
metadata:
  name: access-ml-pipeline
  namespace: ${NS}
spec:
  desc: \"Allow access to Kubeflow Pipelines\"
  selector:
    matchLabels:
      access-ml-pipeline: \"true\"
  volumes:
  - name: volume-kf-pipeline-token
    projected:
      sources:
      - serviceAccountToken:
        path: token
        expirationSeconds: 7200
        audience: pipelines.kubeflow.org
  volumeMounts:
  - mountPath: /var/run/secrets/kubeflow/pipelines
    name: volume-kf-pipeline-token
    readOnly: true
  env:
  - name: KF_PIPELINES_SA_TOKEN_PATH
    value: /var/run/secrets/kubeflow/pipelines/token
 " > ./user-profile-config.yaml

kubectl apply -f ./user-profile-config.yaml

rm -f ./user-profile-config.yaml

