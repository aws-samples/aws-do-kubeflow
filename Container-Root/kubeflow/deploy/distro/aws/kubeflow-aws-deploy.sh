#!/bin/bash

if [ -f ../../../../../.env ]; then
        pushd ../../../../../
        source .env
        popd
fi

echo ""
echo "Deploying AWS Kubeflow ..."

echo "KUBEFLOW_RELEASE_VERSION=$KUBEFLOW_RELEASE_VERSION"
echo "AWS_RELEASE_VERSION=$AWS_RELEASE_VERSION"

echo ""
echo "Cloning repositories ..."

git clone https://github.com/awslabs/kubeflow-manifests.git
cd kubeflow-manifests
git checkout ${AWS_RELEASE_VERSION}

git clone --branch ${KUBEFLOW_RELEASE_VERSION} https://github.com/kubeflow/manifests.git upstream
export REPO_ROOT=$(pwd)

cd $REPO_ROOT

if [ "${KF_AWS_SERVICES_STR}" == "" ]; then
	echo "Deploying Vanilla AWS distribution ..."
	echo "Running kustomize loop ..."
	while ! kustomize build deployments/vanilla | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 30; done

else
	echo "KF_AWS_SERVICES_STR: ${KF_AWS_SERVICES_STR}"

	echo ""
	echo "Managed services integration in this project is still under development" 	
	echo "To try this feature, uncomment the relevant lines in script $0"

	#cd tests/e2e
	#pip install -r requirements.txt
	
	#PYTHONPATH=.. python3 utils/rds-s3/auto-rds-s3-setup.py --region $AWS_REGION --cluster $AWS_CLUSTER_NAME --bucket $S3_BUCKET --s3_aws_access_key_id $AWS_ACCESS_KEY_ID --s3_aws_secret_access_key $AWS_SECRET_ACCESS_KEY

	##while ! kustomize build deployments/rds-s3 | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 30; done
	##while ! kustomize build deployments/rds-s3/rds-only | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 30; done
	##while ! kustomize build deployments/rds-s3/s3-only | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 30; done

fi
