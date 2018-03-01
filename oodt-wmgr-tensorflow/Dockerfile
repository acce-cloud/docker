# Docker image for OODT Workflow Manager with TensorFlow enabled

ARG ACCE_VERSION=latest
FROM acce/oodt-wmgr:${ACCE_VERSION}
MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# install TensorFlow in OODT virtual environment
RUN . $OODT_VENV/bin/activate && \
    pip install tensorflow
