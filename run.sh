#!/bin/bash

source .env

if [ -z "$1" ]; then
	MODE=-d
else
	MODE=-it
fi 

docker container run --net="host" ${RUN_OPTS} ${CONTAINER_NAME} ${MODE} ${NETWORK} ${PORT_MAP} ${VOL_MAP} --platform linux/amd64 ${REGISTRY}${IMAGE}${TAG} $@

