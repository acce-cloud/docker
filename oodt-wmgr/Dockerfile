# Docker image for OODT Workflow Manager and Crawler

ARG ACCE_VERSION=latest
FROM acce/oodt-node:${ACCE_VERSION}
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

# install rabbitmq client module
RUN cd /tmp && \
    git clone https://github.com/acce-cloud/oodt-rabbitmq-clients.git && \
    cd oodt-rabbitmq-clients && \
    cp -R python /usr/local/oodt/rabbitmq

# additional supervisor configuration to start rabbitmq client
#COPY conf/supervisord-rmqclient.conf /etc/supervisor/conf.d/supervisord-rmq-client.conf

# cleanup
RUN rm -rf /tmp/*
RUN rm -rf ~/.m2

EXPOSE 9001
VOLUME $OODT_STAGING
VOLUME $OODT_ARCHIVE

CMD ["/usr/local/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
