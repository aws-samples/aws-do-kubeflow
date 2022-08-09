#!/bin/bash

kubectl -n kubeflow delete pods $(kubectl -n kubeflow get pods | grep -v NAME | cut -d ' ' -f 1)

