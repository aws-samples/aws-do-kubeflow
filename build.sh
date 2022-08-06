#!/bin/bash

source .env

# Build Docker image
docker image build --platform linux/amd64 ${BUILD_OPTS} -t ${REGISTRY}${IMAGE}${TAG} .

