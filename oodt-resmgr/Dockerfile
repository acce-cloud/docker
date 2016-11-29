# Docker image for OODT Resource Manager

FROM oodthub/oodt-node

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# install OODT Resource Manager
COPY pom.xml /tmp/pom.xml
RUN cd /tmp && mvn install

# create symbolic links
RUN cd $OODT_HOME && \
    ln -s ./cas-resource-${OODT_VERSION} ./cas-resource && \
    ln -s ./cas-crawler-${OODT_VERSION} ./cas-crawler

# install scripts
COPY scripts/start.sh /usr/local/bin/start_resmgr.sh
COPY scripts/stop.sh /usr/local/bin/stop_resmgr.sh

# customize properties
COPY conf/logging.properties $OODT_HOME/cas-resource/etc/logging.properties
COPY conf/resource.properties $OODT_HOME/cas-resource/etc/resource.properties
COPY conf/supervisord.conf /etc/supervisor/supervisord-resmgr.conf

EXPOSE 9002
VOLUME $OODT_STAGING
VOLUME $OODT_ARCHIVE

ENTRYPOINT ["/usr/local/bin/start_resmgr.sh"]
#CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord-resmgr.conf"]
