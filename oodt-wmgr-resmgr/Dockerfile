# Docker image for OODT Workflow Manager, Resource Manager and Crawler

FROM oodthub/oodt-node:0.3

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# install OODT Workflow Manager service and Crawler executable
COPY pom.xml /tmp/pom.xml
RUN cd /tmp && mvn install

# create symbolic links
RUN cd $OODT_HOME && \
    ln -s ./cas-workflow-${OODT_VERSION} ./cas-workflow && \
    ln -s ./cas-resource-${OODT_VERSION} ./cas-resource && \
    ln -s ./cas-crawler-${OODT_VERSION} ./cas-crawler

# customize properties
COPY conf/workflow.properties $OODT_HOME/cas-workflow/etc/workflow.properties
COPY conf/logging.properties-wmgr $OODT_HOME/cas-workflow/etc/logging.properties

COPY conf/logging.properties-resmgr $OODT_HOME/cas-resource/etc/logging.properties
COPY conf/resource.properties $OODT_HOME/cas-resource/etc/resource.properties
COPY conf/nodes.xml $OODT_HOME/cas-resource/policy/nodes.xml
COPY conf/node-to-queue-mapping.xml $OODT_HOME/cas-resource/policy/node-to-queue-mapping.xml

COPY conf/supervisord.conf /etc/supervisor/supervisord-workflow-resource.conf

# install scripts
COPY scripts/start.sh /usr/local/bin/start.sh
COPY scripts/stop.sh /usr/local/bin/stop.sh

EXPOSE 9001
EXPOSE 9002
VOLUME $OODT_STAGING
VOLUME $OODT_ARCHIVE

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord-workflow-resource.conf"]
