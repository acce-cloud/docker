# Base Docker image for OODT services.
# It requires only a JRE, and adds env variables and directory structure.
FROM openjdk:9-jre

# install latest security patches
RUN apt-get update

# default OODT environment (inherited by all child images)
ENV OODT_VERSION 1.0
ENV OODT_HOME /usr/local/oodt

ENV FILEMGR_URL http://localhost:9000/
ENV WORKFLOW_URL http://localhost:9001/

ENV OODT_CONFIG ${OODT_HOME}/workflows
ENV PGE_ROOT $OODT_HOME/pges
ENV OODT_ARCHIVE ${OODT_HOME}/archive
ENV OODT_STAGING ${OODT_HOME}/staging

# create directories
RUN mkdir -p $OODT_HOME
RUN mkdir -p $OODT_CONFIG
RUN mkdir -p $PGE_ROOT
RUN mkdir -p $OODT_ARCHIVE
RUN mkdir -p $OODT_STAGING
RUN mkdir -p $OODT_HOME/run

# cleanup
RUN apt-get clean && \
    apt-get autoclean && \
    apt-get autoremove
