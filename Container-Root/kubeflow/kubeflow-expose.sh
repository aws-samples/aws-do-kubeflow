#!/bin/bash
kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80 &


