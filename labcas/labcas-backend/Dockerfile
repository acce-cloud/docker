# Docker image containig core LabCAS back-end services.

FROM oodthub/labcas-node

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# checkout LabCAS source
ENV LABCAS_SRC /tmp
RUN cd $LABCAS_SRC && \
    git clone https://github.com/EDRN/labcas-backend.git && \
    cd labcas-backend && \
    git checkout -b devel origin/devel

# install services into $LABCAS_HOME
RUN cd $LABCAS_SRC/labcas-backend && \
    mvn install

# expose service ports
EXPOSE 9000 9001 9002 8983

# start labcas services
COPY scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY conf/ /etc/supervisor/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
