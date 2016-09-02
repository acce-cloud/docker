# Docker image for OODT Workflow Manager and Crawler

FROM oodthub/oodt-node

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# install OODT Workflow Manager service and Crawler executable
COPY pom.xml /tmp/pom.xml
RUN cd /tmp && mvn install

# create symbolic links
RUN cd $OODT_HOME && \
    ln -s ./cas-workflow-${OODT_VERSION} ./cas-workflow && \
    ln -s ./cas-crawler-${OODT_VERSION} ./cas-crawler

# customize workflow.properties
COPY workflow.properties $OODT_HOME/cas-workflow/etc/workflow.properties

# install scripts
COPY start.sh /usr/local/bin/start-wmgr.sh
COPY stop.sh /usr/local/bin/stop-wmgr.sh
COPY supervisord.conf /etc/supervisor/supervisord-workflow.conf

EXPOSE 9001
VOLUME $OODT_STAGING
VOLUME $OODT_ARCHIVE

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord-workflow.conf"]
