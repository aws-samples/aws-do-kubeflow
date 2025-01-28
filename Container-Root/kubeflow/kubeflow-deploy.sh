#!/bin/bash

# Deploys the Kubeflow configuration specified in .env

if [ -f /wd/.env ]; then
	source /wd/.env
fi

case "$KF_DISTRO" in 

	"generic")
		pushd deploy/distro/generic
		./kubeflow-generic-deploy.sh
		;;
	"aws")
		pushd deploy/distro/aws
		./kubeflow-aws-deploy.sh
		;;
	*)
		echo ""
		echo "KF_DISTRO $KF_DISTRO is not supported"
		echo "Please configure the project with a supported Kubeflow distribution and try again"
		;;
esac
	
