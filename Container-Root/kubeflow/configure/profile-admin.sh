#!/bin/bash

if [ "$1" == "" ]; then
	export NS=kubeflow-user-example-com
	echo "Argument not provided, assuming default user namespace $NS ..."
else
	export NS=$1
fi

kubectl -n ${NS} create clusterrolebinding ${NS}-cluster-admin-binding --clusterrole=cluster-admin --user=system:serviceaccount:${NS}:default-editor

