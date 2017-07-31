# Docker image for OODT File Manager configured with Solr back-end

FROM oodthub/oodt-node:0.3

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# install OODT File Manager, Workflow Manager and Crawler
COPY pom.xml /tmp/pom.xml
RUN cd /tmp && mvn install

# create symbolic links
RUN cd $OODT_HOME && \
    ln -s ./cas-filemgr-${OODT_VERSION} ./cas-filemgr && \
    ln -s ./cas-workflow-${OODT_VERSION} ./cas-workflow && \
    ln -s ./cas-crawler-${OODT_VERSION} ./cas-crawler

# create directories that don't exist
RUN mkdir -p ${OODT_HOME}/cas-filemgr/logs

# customize properties
COPY conf/filemgr.properties $OODT_HOME/cas-filemgr/etc/filemgr.properties
COPY conf/logging.properties-filemgr $OODT_HOME/cas-filemgr/etc/logging.properties
COPY conf/workflow.properties $OODT_HOME/cas-workflow/etc/workflow.properties
COPY conf/logging.properties-wmgr $OODT_HOME/cas-workflow/etc/logging.properties
COPY conf/supervisord.conf /etc/supervisor/supervisord.conf

# expose ports to other containers
EXPOSE 9000
EXPOSE 9001

# install start/stop scripts
COPY scripts/start.sh /usr/local/bin/start-all.sh
COPY scripts/stop.sh /usr/local/bin/stop-all.sh
#COPY scripts/test.sh /usr/local/bin/test.sh

# share archive directory
VOLUME $OODT_STAGING
VOLUME $OODT_ARCHIVE

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
#ENTRYPOINT ["/usr/local/bin/start-all.sh"]
