# Image containing configuration for LabCAS 'labacas-test' workflow

FROM oodthub/labcas-node

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# checkout LabCAS source
ENV LABCAS_SRC /tmp
RUN cd $LABCAS_SRC && \
    git clone https://github.com/EDRN/labcas-backend.git && \
    cd labcas-backend && \
    git checkout -b devel origin/devel

# install labcas-test configuration into $LABCAS_HOME/workflows/labcas-test
RUN cd $LABCAS_SRC/labcas-backend && \
    mvn install -Dworkflow=labcas-test

VOLUME $LABCAS_HOME/workflows/labcas-test
VOLUME $LABCAS_ARCHIVE/labcas-test
