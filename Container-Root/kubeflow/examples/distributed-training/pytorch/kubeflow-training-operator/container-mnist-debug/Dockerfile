ARG BASE_IMAGE=docker.io/kubeflowkatib/pytorch-mnist:v1beta1-45c5727
FROM $BASE_IMAGE

# install debugging library
RUN pip install debugpy

COPY mnist-debug.py /opt/pytorch-mnist/
