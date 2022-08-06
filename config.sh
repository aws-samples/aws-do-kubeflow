#!/bin/bash


######################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. #
# SPDX-License-Identifier: MIT-0                                     #
######################################################################

print_help() {
	echo ""
	echo "Usage: $0"
	echo ""
	echo "   This script just opens the configuration file (.env) in a text editor."
	echo "   By default we use vi, but this can be easily changed by modifying the script."
	echo "   Here you can change AWS_CLUSTER_NAME and AWS_REGION."
	echo "   Changes to the config file take effect with the next action script execution."
	echo ""
}

if [ "$1" == "" ]; then
	r=$(which vim)
	if [ "$?" == "0" ]; then
		vim -c ":syntax on" ./.env
	else
		vi ./.env
	fi
else
	print_help
fi
