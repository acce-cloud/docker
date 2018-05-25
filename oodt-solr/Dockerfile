# Solr image configured as backend of the OODT File Manager
FROM solr:5.3

USER root

# apply latest security patches
RUN apt-get update

ENV OODT_HOME /usr/local/oodt

# copy solr-home directory tree (recursively)
ENV SOLR_HOME ${OODT_HOME}/solr-home
COPY solr-home/ $SOLR_HOME/
RUN chown -R solr:solr $SOLR_HOME/

# location of Solr mindex
ENV SOLR_DATA_DIR ${OODT_HOME}/solr-index
RUN mkdir -p $SOLR_DATA_DIR
RUN chown -R solr:solr $SOLR_DATA_DIR

# run Solr as non-privielged 'solr' user
USER solr
WORKDIR /opt/solr/bin
ENTRYPOINT ./solr start -f -p 8983 -s ${SOLR_HOME} -Dsolr.autoSoftCommit.maxTime=5000 -Dsolr.autoCommit.maxTime=10000 -a '-Dsolr.data.dir=${SOLR_DATA_DIR}'
