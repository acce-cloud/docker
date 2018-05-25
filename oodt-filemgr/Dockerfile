# Docker image for OODT File Manager configured with Solr back-end

ARG ACCE_VERSION=latest

FROM maven:3.5.3-jdk-9 as oodt-build

# install OODT File Manager
ENV OODT_VERSION=1.0
ENV OODT_HOME=/usr/local/oodt
COPY pom.xml /tmp/pom.xml
RUN cd /tmp && mvn install

FROM acce/oodt-node:${ACCE_VERSION}
RUN apt-get update

COPY --from=oodt-build ${OODT_HOME} ${OODT_HOME}

# create symbolic links
RUN cd $OODT_HOME && \
    ln -s ./cas-filemgr-${OODT_VERSION} ./cas-filemgr

# create directories that don't exist
RUN mkdir -p ${OODT_HOME}/cas-filemgr/logs

# customize properties
COPY conf/filemgr.properties $OODT_HOME/cas-filemgr/etc/filemgr.properties
COPY conf/logging.properties $OODT_HOME/cas-filemgr/etc/logging.properties

# expose port to other containers
EXPOSE 9000

# shared directories
VOLUME $OODT_ARCHIVE

WORKDIR ${OODT_HOME}/cas-filemgr/bin
CMD ./filemgr start && tail -f ${OODT_HOME}/cas-filemgr/logs/cas_filemgr.log
