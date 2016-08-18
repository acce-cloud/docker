# LabCAS 'labacas-test' workflow

FROM oodthub/oodt-node

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

ENV LABCAS_HOME /usr/local/oodt
ENV LABCAS_ARCHIVE /usr/local/oodt/archive

RUN mkdir -p $LABCAS_HOME/workflows/labcas-test
COPY workflows/labcas-test/ $LABCAS_HOME/workflows/labcas-test/
RUN mkdir -p $LABCAS_ARCHIVE/labcas-test

VOLUME $LABCAS_HOME/workflows/labcas-test
VOLUME $LABCAS_ARCHIVE/labcas-test
