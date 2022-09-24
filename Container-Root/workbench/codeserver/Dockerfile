FROM public.ecr.aws/j1r0q0g6/notebooks/notebook-servers/codeserver-python:v1.5.0

MAINTAINER Alex Iankoulski <iankouls@amazon.com>

ARG http_proxy
ARG https_proxy
ARG no_proxy

ADD Container-Root /

USER root

RUN export http_proxy=$http_proxy; export https_proxy=$https_proxy; export no_proxy=$no_proxy; /setup.sh; rm -f /setup.sh

ENTRYPOINT []

USER jovyan

CMD /startup.sh
