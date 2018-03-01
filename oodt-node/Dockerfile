# Docker image for OODT services. Includes:
#
# -) Some utilities: Git, tar, wget, curl
# -) Java
# -) Maven
# -) Python
# -) Supervisor

FROM ubuntu

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

RUN apt-get update

# install Git
RUN apt-get install -y git tar curl wget unzip

# install JRE
RUN apt-get install -y default-jre
ENV JAVA_HOME=/usr/lib/jvm/default-java

# install Maven
# Apache Maven 3.3.9
# Maven home: /usr/share/maven
RUN apt-get install -y maven
ENV MAVEN_HOME /usr/share/maven
#VOLUME /root/.m2

# install Python and basic modules
RUN apt-get install -y python2.7
RUN apt-get install -y python-pip python-dev build-essential 
RUN pip install --upgrade pip
RUN pip install --upgrade virtualenv

# create Python virtual environment to install OODT dependencies
RUN cd /usr/local && \
    virtualenv oodt_venv
ENV OODT_VENV /usr/local/oodt_venv

# install other Python modules needed by OODT
RUN . ${OODT_VENV}/bin/activate && \
    pip install argparse pika requests

# install Supervisor into system Python 
RUN pip install supervisor
RUN mkdir -p /var/log/supervisor
COPY conf/supervisord.conf /etc/supervisor/supervisord.conf

# default OODT environment (inherited by all child images)
ENV OODT_VERSION 1.0
ENV OODT_HOME /usr/local/oodt

ENV FILEMGR_URL http://localhost:9000/
ENV WORKFLOW_URL http://localhost:9001/
ENV RESMGR_URL http://localhost:9002/

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
