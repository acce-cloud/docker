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

# customize properties
COPY conf/workflow.properties $OODT_HOME/cas-workflow/etc/workflow.properties
COPY conf/logging.properties $OODT_HOME/cas-workflow/etc/logging.properties
COPY conf/supervisord-wmgr.conf /etc/supervisor/conf.d/supervisord-wmgr.conf

EXPOSE 9001
VOLUME $OODT_STAGING
VOLUME $OODT_ARCHIVE

CMD ["/usr/local/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
