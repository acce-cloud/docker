# Docker image for LabCAS installation server
# This image super-impose the LabCAS environment on top of the existing OODT environment

FROM oodthub/oodt-node

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

ENV LABCAS_HOME $OODT_HOME
ENV LABCAS_ARCHIVE $OODT_ARCHIVE

# install python utilities
RUN yum -y update && \
    yum install -y python-argparse
