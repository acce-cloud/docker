# Docker image for OODT Workflow Manager and Crawler

ARG ACCE_VERSION=latest

FROM maven:3.5.3-jdk-9 as oodt-build

# install OODT Workflow Manager and Crawler executable
ENV OODT_VERSION=1.0
ENV OODT_HOME=/usr/local/oodt
COPY pom.xml /tmp/pom.xml
RUN cd /tmp && mvn install

FROM acce/oodt-node:${ACCE_VERSION}
RUN apt-get update

COPY --from=oodt-build ${OODT_HOME} ${OODT_HOME}

# create symbolic links
RUN cd $OODT_HOME && \
    ln -s ./cas-workflow-${OODT_VERSION} ./cas-workflow && \
    ln -s ./cas-crawler-${OODT_VERSION} ./cas-crawler

# customize properties
COPY conf/workflow.properties $OODT_HOME/cas-workflow/etc/workflow.properties
COPY conf/logging.properties $OODT_HOME/cas-workflow/etc/logging.properties

COPY conf/wmgr $OODT_HOME/cas-workflow/bin/wmgr

# expose port to other containers
EXPOSE 9001

# shared volumes
VOLUME $OODT_STAGING
VOLUME $OODT_ARCHIVE

WORKDIR ${OODT_HOME}/cas-workflow/bin
CMD ./wmgr start && tail -f ${OODT_HOME}/cas-workflow/logs/cas_workflow.log
