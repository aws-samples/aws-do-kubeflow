#!/bin/bash

if [ -f /wd/.env ]; then
  pushd /wd/
  source .env
  popd
elif [ -f ../../../../.env ]; then
  pushd ../../../../
  source .env
  popd
else
  echo ".env could not be located, exitting ..."
  exit 1
fi

# complete removal of CloudWatch Container Insights
curl -s https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluentd-quickstart.yaml | sed "s/{{cluster_name}}/${AWS_CLUSTER_NAME}/;s/{{region_name}}/${AWS_REGION}/" | kubectl delete -f -


