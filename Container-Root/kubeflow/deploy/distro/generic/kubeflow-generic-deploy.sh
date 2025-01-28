#!/bin/bash

source ../check_prerequisites.sh

if [ "$ALL_CHECKS_PASSED" != "true" ]; then
    echo "Environment variable ALL_CHECKS_PASSED is not true. Exiting script. Please check the output and run this script again."
    exit 1
fi

# if [ -f ../../../../../.env ]; then
# 	pushd ../../../../../
# 	source .env
# 	popd
# fi

if [ -f /wd/.env ]; then
	source /wd/.env
fi

echo ""
echo "Deploying opensource Kubeflow ..."

mkdir -p "$KF_DIR"
pushd "$KF_DIR"



###################################
##################################

echo "KUBEFLOW_RELEASE_VERSION=$KUBEFLOW_RELEASE_VERSION"

echo ""
echo "Cloning repositories ..."

git clone --branch ${KUBEFLOW_RELEASE_VERSION} https://github.com/kubeflow/manifests.git
export REPO_ROOT=$(pwd)/manifests

pushd $REPO_ROOT

export KF_INSTALLED=false
if [ "${KF_AWS_SERVICES_STR}" == "" ]; then
        echo "Deploying OSS Kubeflow ..."
        echo "Running kustomize loop ..."
        while ! kustomize build example | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 30; done
        echo ""
        echo "Waiting for all Kubeflow pods to start Running ..."
        sleep 3
        CNT=$(kubectl -n kubeflow get pods | grep -v NAME | grep -v Running | wc -l)
        while [ ! "$CNT" == "0" ]; do
                echo ""
                echo "Waiting for all Kubeflow pods to start Running ..."
                sleep 3
                CNT=$(kubectl -n kubeflow get pods | grep -v NAME | grep -v Running | wc -l)
        done
        echo ""
        echo "Restarting central dashboard ..."
        kubectl -n kubeflow delete pod $(kubectl -n kubeflow get pods | grep centraldashboard | cut -d ' ' -f 1)
        export KF_INSTALLED=true
else
        echo "KF_AWS_SERVICES_STR: ${KF_AWS_SERVICES_STR}"

        echo ""
        echo "Managed services integration in this project is still under development" 
        echo "To try this feature, uncomment the relevant lines in script $0"

        #pushd tests/e2e
        #pip install -r requirements.txt

        #PYTHONPATH=.. python3 utils/rds-s3/auto-rds-s3-setup.py --region $AWS_REGION --cluster $AWS_CLUSTER_NAME --bucket $S3_BUCKET --s3_aws_access_key_id $AWS_ACCESS_KEY_ID --s3_aws_secret_access_key $AWS_SECRET_ACCESS_KEY

        ##while ! kustomize build deployments/rds-s3 | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 30; done
        ##while ! kustomize build deployments/rds-s3/rds-only | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 30; done
        ##while ! kustomize build deployments/rds-s3/s3-only | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 30; done
        ##popd

        export KF_INSTALLED=false

fi

popd
popd

echo ""
if [ "${KF_INSTALLED}" == "true" ]; then
        echo "Kubeflow deployment succeeded" 
        if [ "${KF_CLUSTER_ACCESS}" == "true" ]; then
                echo "Granting cluster access to kubeflow profile user ..."
                ../../../configure/profile-admin.sh
        fi
        if [ "${KF_PIPELINES_ACCESS}" == "true" ]; then
                echo "Setting up access to Kubeflow Pipelines ..."
                ../../../configure/profile-pod-default.sh
        fi
else
        echo "Kubeflow deployment failed"
fi



#################################
#################################

