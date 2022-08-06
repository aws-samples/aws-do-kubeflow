FROM ubuntu:22.04

ARG http_proxy
ARG https_proxy
ARG no_proxy

ADD Container-Root /

ENV DEBIAN_FRONTEND=noninteractive

RUN export http_proxy=$http_proxy; export https_proxy=$https_proxy; export no_proxy=$no_proxy; /setup.sh; rm -f /setup.sh

WORKDIR /kubeflow

CMD /startup.sh

