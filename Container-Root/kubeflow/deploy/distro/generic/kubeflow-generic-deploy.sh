#!/bin/bash

if [ -f ../../../../../.env ]; then
	pushd ../../../../../
	source .env
	popd
fi

echo ""
echo "Deploying opensource Kubeflow ..."

mkdir -p "$KF_DIR"
cd "$KF_DIR"

# Configure deployment
curl -o kfctl_aws.yaml $CONFIG_URI

sed -i "/region: us-west-2/ a \      enablePodIamPolicy: true" ${CONFIG_FILE}

sed -i -e 's/kubeflow-aws/'"$AWS_CLUSTER_NAME"'/' ${CONFIG_FILE}
sed -i "s@us-west-2@$AWS_REGION@" ${CONFIG_FILE}

sed -i "s@roles:@#roles:@" ${CONFIG_FILE}
sed -i "s@- eksctl-$AWS_CLUSTER_NAME-nodegroup-ng-a2-NodeInstanceRole-xxxxxxx@#- eksctl-$AWS_CLUSTER_NAME-nodegroup-ng-a2-NodeInstanceRole-xxxxxxx@" ${CONFIG_FILE}

kfctl apply -V -f ${CONFIG_FILE}

