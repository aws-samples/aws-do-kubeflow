#!/bin/bash
source ../check_prerequisites.sh

if [ "$ALL_CHECKS_PASSED" != "true" ]; then
    echo "Environment variable ALL_CHECKS_PASSED is not true. Exiting script. Please check the output and run this script again."
    #exit 1
fi

if [ -f /wd/.env ]; then
        source /wd/.env
fi


echo ""


echo "Deploying AWS Kubeflow ..."

echo "KUBEFLOW_RELEASE_VERSION=$OSS_KUBEFLOW_RELEASE_VERSION_FOR_AWS"
echo "AWS_RELEASE_VERSION=$AWS_RELEASE_VERSION"

echo ""
echo "Cloning repositories ..."

git clone https://github.com/awslabs/kubeflow-manifests.git

pushd kubeflow-manifests

git checkout ${AWS_RELEASE_VERSION}

git clone --branch ${OSS_KUBEFLOW_RELEASE_VERSION_FOR_AWS} https://github.com/kubeflow/manifests.git upstream

# As some of the Kubeflow depolyment manifests still rely on v2beta2 for some of the components (e.g. knative-serving HorizontalPodAutoscaler), we need to 
# remove v2beta2 and replace with v2 to avoid conflicts due to unsupported versions
grep -rl 'autoscaling/v2beta2' . | xargs sed -i 's/autoscaling\/v2beta2/autoscaling\/v2/g'

export REPO_ROOT=$(pwd)

pushd $REPO_ROOT

# Kubeflow customizations
echo "Applying Kubeflow customizations..."

# Create a patch file for authservice StatefulSet
cat <<EOF > authservice-patch.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: authservice
  namespace: istio-system
spec:
  template:
    spec:
      initContainers:
      - name: fix-permission
        image: busybox
        command: ['sh', '-c']
        args: ['chmod -R 777 /var/lib/authservice;']
        volumeMounts:
        - mountPath: /var/lib/authservice
          name: data
      containers:
      - name: authservice
        image: docker.io/kubeflowmanifestswg/oidc-authservice:e236439
EOF

# Create RBAC and VirtualService configurations
cat <<EOF > kubeflow-configs.yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: jupyter-web-app
  namespace: kubeflow
spec:
  gateways:
  - kubeflow-gateway
  hosts:
  - '*'
  http:
  - match:
    - uri:
        prefix: /jupyter
    rewrite:
      uri: /
    route:
    - destination:
        host: jupyter-web-app-service.kubeflow.svc.cluster.local
        port:
          number: 80
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: notebook-controller-role
rules:
- apiGroups:
  - apps
  resources:
  - statefulsets
  - deployments
  verbs:
  - '*'
- apiGroups:
  - ""
  resources:
  - pods
  - services
  - events
  verbs:
  - '*'
- apiGroups:
  - kubeflow.org
  resources:
  - notebooks
  - notebooks/status
  - notebooks/finalizers
  verbs:
  - '*'
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: notebook-controller-istio-role
rules:
- apiGroups:
  - networking.istio.io
  resources:
  - virtualservices
  verbs:
  - '*'
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: notebook-controller-istio-binding
subjects:
- kind: ServiceAccount
  name: notebook-controller-service-account
  namespace: kubeflow
roleRef:
  kind: ClusterRole
  name: notebook-controller-istio-role
  apiGroup: rbac.authorization.k8s.io
EOF



export KF_INSTALLED=false
if [ "${KF_AWS_SERVICES_STR}" == "" ]; then
        echo "Deploying Vanilla AWS distribution ..."
        echo "Running kustomize loop ..."
        while ! kustomize build deployments/vanilla | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 30; done

        # Apply customizations after initial deployment
        kubectl patch statefulset authservice -n istio-system --patch "$(cat authservice-patch.yaml)"
        kubectl apply -f kubeflow-configs.yaml

        # Restarting necessary deployments
        echo "Restarting necessary deployments..."
        kubectl rollout restart deployment jupyter-web-app-deployment -n kubeflow
        kubectl rollout restart deployment notebook-controller-deployment -n kubeflow
        kubectl delete pod authservice-0 -n istio-system

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