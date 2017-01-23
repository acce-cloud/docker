# Docker image for running rabbit framework for biomarker discovery

FROM oodthub/labcas-backend

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# install yum dependencies for R installation
RUN yum -y update && \
    yum install -y libcurl \
    libcurl-devel \
    openssl-devel \
    libxml2-devel \
    ed \
    tar \
    && yum clean all

# install R 
RUN yum -y install epel-release; yum clean all
RUN yum -y install R; yum clean all
RUN mkdir -p /usr/share/doc/R-3.3.1/html

# install R dependencies
COPY packages.R /tmp/packages.R
RUN cd /tmp && \
    R CMD BATCH  packages.R

# install latest version of labcas biomarker-discovery workflow into $LABCAS_HOME
RUN cd $LABCAS_SRC/labcas-backend && \
    git pull && \
    mvn install -Dworkflow=biomarker-discovery
