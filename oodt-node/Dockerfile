# Docker image for OODT installation server. Includes:
# -) some system utilities
# -) Java 8
# -) Maven
# -) Supervisor

FROM centos:centos6.7

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# Update to last version
RUN yum -y update; yum clean all

# install system utilities
RUN yum -y update && \
    yum -y install git lsof unzip python-argparse python-setuptools python-pip tar wget zip && \
    yum clean all

# Java 8
ENV JAVA_VERSION 8u31
ENV BUILD_VERSION b13
RUN wget --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/$JAVA_VERSION-$BUILD_VERSION/jdk-$JAVA_VERSION-linux-x64.rpm" -O /tmp/jdk-8-linux-x64.rpm
RUN yum -y install /tmp/jdk-8-linux-x64.rpm && \
    rm /tmp/jdk-8-linux-x64.rpm
RUN alternatives --install /usr/bin/java jar /usr/java/latest/bin/java 200000
RUN alternatives --install /usr/bin/javaws javaws /usr/java/latest/bin/javaws 200000
RUN alternatives --install /usr/bin/javac javac /usr/java/latest/bin/javac 200000
ENV JAVA_HOME /usr/java/latest

# Maven
ENV MAVEN_VERSION 3.3.9
RUN mkdir -p /usr/share/maven \
    && curl -fsSL http://mirrors.sonic.net/apache/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
       | tar -xzC /usr/share/maven --strip-components=1 \
    && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn
ENV MAVEN_HOME /usr/share/maven
VOLUME /root/.m2

# install Supervisor
RUN easy_install supervisor
RUN mkdir -p /var/log/supervisor

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
