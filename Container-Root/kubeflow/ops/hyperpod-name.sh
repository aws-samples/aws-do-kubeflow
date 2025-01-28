#!/bin/bash

# Display hyperpod cluster name, corresponding to a specified EKS cluster name

usage(){
        echo ""
        echo "Finds the name of the SageMaker HyperPod cluster, corresponding to a given EKS cluster"
        echo "Usage: $0 [EKS_CLUSTER_NAME]"
        echo "       EKS_CLUSTER_NAME - name of EKS cluster. If not specified, the current Kubernetes context will be used"
        echo ""
}

if [ "$1" == "--help" ]; then
        usage
elif [ ! "$1" == "" ]; then
        EKS_CLUSTER_NAME=$1
else
        EKS_CLUSTER_NAME=$AWS_EKS_CLUSTER
fi

export HYPERPOD_CLUSTER_NAME=""

if [ "$EKS_CLUSTER_NAME" == "" ]; then
        echo "" >&2
        echo "Could not determine EKS_CLUSTER_NAME" >&2
        echo "" >&2
else
        echo "" >&2
        echo "Looking for HyperPod cluster, associated with EKS cluster $EKS_CLUSTER_NAME ..." >&2
        echo "" >&2
        HP_CLUSTERS=$(aws sagemaker list-clusters --region $AWS_REGION --query 'ClusterSummaries[].ClusterName' --output text)
        for HP_CLUSTER in $HP_CLUSTERS; do
                EKS_CLUSTER_ARN=$(aws sagemaker describe-cluster --cluster-name $HP_CLUSTER --region $AWS_REGION --query Orchestrator.Eks.ClusterArn --output text)
                MAYBE_EKS_CLUSTER_NAME=$(echo $EKS_CLUSTER_ARN | awk -F'/' '{print $NF}')
                # Check if the EKS cluster name matches the expected one
                if [[ "$MAYBE_EKS_CLUSTER_NAME" == "$EKS_CLUSTER_NAME" ]]; then
                        echo "Match found! Hyperpod cluster: $HP_CLUSTER is associated with EKS cluster: $EKS_CLUSTER_NAME" >&2
                        export HYPERPOD_CLUSTER_NAME=$HP_CLUSTER
                        break
                else
                        echo "Not a match. HyperPod cluster: $HP_CLUSTER is associated with EKS cluster: $MAYBE_EKS_CLUSTER_NAME" >&2
                fi
        done

fi

echo $HYPERPOD_CLUSTER_NAME