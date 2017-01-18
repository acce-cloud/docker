# Docker image for OODT installation server. Includes:
# -) some system utilities
# -) Java 8
# -) Maven
# -) Supervisor

FROM centos:6

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# Update to last version
RUN yum -y update; yum clean all

# install system utilities
RUN yum -y update && \
    yum -y install gcc \
                   git \
                   lsof \
                   openssl \
                   openssl-devel \
                   tar \
                   unzip \
                   wget \
                   zip \
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

# install Python 2.7
# note: option "--enable-shared" is needed by mod_wsgi, will generate /usr/local/lib/libpython2.7.so.1.0
ENV PYTHON_VERSION 2.7.13
RUN cd /tmp && \
    wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && \
    tar xvfz Python-${PYTHON_VERSION}.tgz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --prefix=/usr/local --enable-shared && \
    make && \
    make altinstall
RUN ln -s /usr/local/bin/python2.7 /usr/local/bin/python
ENV PATH=/usr/local/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/local/bin/python:$LD_LIBRARY_PATH

# install additional core Python packages
RUN cd /tmp
RUN wget --no-check-certificate https://bootstrap.pypa.io/ez_setup.py
RUN python ez_setup.py --insecure
RUN rm -rf ez_setup.py
RUN easy_install pip
RUN pip install argparse
RUN pip install pika
RUN pip install requests

# Maven
ENV MAVEN_VERSION 3.3.9
RUN mkdir -p /usr/share/maven \
    && curl -fsSL http://mirrors.sonic.net/apache/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
       | tar -xzC /usr/share/maven --strip-components=1 \
    && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn
ENV MAVEN_HOME /usr/share/maven
VOLUME /root/.m2

# install Supervisor
# /usr/local/bin/python ==> installs executable under /usr/local/bin/supervisord
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
