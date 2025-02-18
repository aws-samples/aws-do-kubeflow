#!/bin/bash
# This script intergrates your EKS cluster or EKS Hyperpod Cluster with Amazon FSx for Lustre.
# To learn more about FSx and the steps involved in setting it up, please refer to the following links
# https://aws.amazon.com/blogs/opensource/using-fsx-lustre-csi-driver-amazon-eks/
# https://docs.aws.amazon.com/eks/latest/userguide/fsx-csi.html
# https://github.com/kubernetes-sigs/aws-fsx-csi-driver
# This is sourced from the Amazon EKS Support in Amazon SageMaker workshop studio

set -e

if [ -f /wd/.env ]; then
	source /wd/.env
fi

# Create an IAM OIDC identity provider for your cluster with the following command:

eksctl utils associate-iam-oidc-provider --cluster $AWS_EKS_CLUSTER --approve

# Deploy the FSx for Lustre CSI driver:

helm repo add aws-fsx-csi-driver https://kubernetes-sigs.github.io/aws-fsx-csi-driver

helm repo update

helm upgrade --install aws-fsx-csi-driver aws-fsx-csi-driver/aws-fsx-csi-driver\
  --namespace kube-system

# Use the eksctl CLI  to create an IAM role bound to the service account used by the driver, attaching the AmazonFSxFullAccess AWS-managed policy:

eksctl create iamserviceaccount \
  --name fsx-csi-controller-sa \
  --override-existing-serviceaccounts \
  --namespace kube-system \
  --cluster $AWS_EKS_CLUSTER \
  --attach-policy-arn arn:aws:iam::aws:policy/AmazonFSxFullAccess \
  --approve \
  --role-name AmazonEKSFSxLustreCSIDriverFullAccess \
  --region $AWS_REGION

# Annotate the driver's service account with the ARN of the AmazonEKSFSxLustreCSIDriverFullAccess IAM role that was created:

SA_ROLE_ARN=$(aws iam get-role --role-name AmazonEKSFSxLustreCSIDriverFullAccess --query 'Role.Arn' --output text)

kubectl annotate serviceaccount -n kube-system fsx-csi-controller-sa \
  eks.amazonaws.com/role-arn=${SA_ROLE_ARN} --overwrite=true

# This annotation lets the driver know what IAM role it should use to interact with the FSx for Lustre service on your behalf.

# Verify that the service account has been properly annotated:

kubectl get serviceaccount -n kube-system fsx-csi-controller-sa -oyaml

# Restart the fsx-csi-controller deployment for the changes to take effect:

kubectl rollout restart deployment fsx-csi-controller -n kube-system
