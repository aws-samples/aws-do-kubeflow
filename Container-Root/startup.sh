#!/bin/bash

# Container startup script
echo "Container-Root/startup.sh executed"

echo ""
echo "Constructing array of services ..."
echo "KF_AWS_SERVICES_STR=$KF_AWS_SERVICES_STR"
KF_AWS_SERVICES_SP="$(echo $KF_AWS_SERVICES_STR | tr '-' ' ')"
export KF_AWS_SERVICES=($KF_AWS_SERVICES_SP)
echo "${#KF_AWS_SERVICES[@]} services parsed"
echo "KF_AWS_SERVICES=(${KF_AWS_SERVICES[@]})"
echo ""

while true; do echo do-kubeflow container is running at $(date); sleep 10; done
