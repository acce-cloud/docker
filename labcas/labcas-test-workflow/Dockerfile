# LabCAS 'labacas-test' workflow

FROM oodthub/oodt-node

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

ENV LABCAS_HOME /usr/local/oodt

RUN mkdir -p $LABCAS_HOME/workflows/labcas-test
COPY workflows/labcas-test/ $LABCAS_HOME/workflows/labcas-test/

VOLUME $LABCAS_HOME/workflows/labcas-test
