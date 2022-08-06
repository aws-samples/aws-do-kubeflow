#!/bin/sh

if [ -f /wd/.env ]; then
  source /wd/.env
elif [ -f ../../../.env ]; then
  source ../../../.env
else
  echo ".env could not be located, exitting ..."
  exit 1
fi

# Export the Worker Role Name 
STACK_NAME=$(eksctl get nodegroup --cluster ${AWS_CLUSTER_NAME} -o json | jq -r '.[].StackName')
ROLE_NAME=$(aws cloudformation describe-stack-resources --stack-name $STACK_NAME | jq -r '.StackResources[] | select(.ResourceType=="AWS::IAM::Role") | .PhysicalResourceId')
echo "export ROLE_NAME=${ROLE_NAME}" | tee -a ~/.bash_profile


# Ensuring the role name our workers use is set in our environment, if not set visit https://www.eksworkshop.com/030_eksctl/test/
test -n "$ROLE_NAME" && echo ROLE_NAME is "$ROLE_NAME" || echo ROLE_NAME is not set

# Attach policy to the nodes IAM Role
aws iam attach-role-policy \
  --role-name $ROLE_NAME \
  --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy


# Verify that the policy has been attached to the IAM Role
aws iam list-attached-role-policies --role-name $ROLE_NAME | grep CloudWatchAgentServerPolicy || echo 'Policy not found'

# Completing setup of container insights
curl -s https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluentd-quickstart.yaml | sed "s/{{cluster_name}}/${AWS_CLUSTER_NAME}/;s/{{region_name}}/${AWS_REGION}/" | kubectl apply -f -


# Verifying tjat daemon sets have been deployed
kubectl -n amazon-cloudwatch get daemonsets

# Use this link to see the cloudwatch containers UI
echo "
Use the URL below to access Cloudwatch Container Insights in $AWS_REGION:

https://console.aws.amazon.com/cloudwatch/home?region=${AWS_REGION}#cw:dashboard=Container;context=~(clusters~'${AWS_CLUSTER_NAME}~dimensions~(~)~performanceType~'Service)"

