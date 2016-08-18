# Docker image for OODT Crawler

FROM oodthub/oodt-node

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# install OODT crawler
COPY pom.xml /tmp/pom.xml
RUN cd /tmp && mvn install

# create symbolic links
RUN cd $OODT_HOME && \
    ln -s ./cas-crawler-${OODT_VERSION} cas-crawler

VOLUME $OODT_HOME/cas-crawler

# keep container running 
# so workflow manager container can access crawler configuration
#ENTRYPOINT ["tail", "-f", "/dev/null"]
