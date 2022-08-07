#!/bin/bash

kubectl -n kubeflow delete pods $(kubectl -n kubeflow get pods | cut -d ' ' -f 1)

