# Docker image for running the 'test-workflow' in a docker-compose environment.
# This image can be used to add custom configuration onto existing File Manager and Workflow Manager services.
#
# Note: this image extends the core oodthub/oodt-node (which has no OODT services installed).
# Note: the published files will be of product type "TestFile".

FROM oodthub/oodt-node

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# install custom OODT File Manager configuration
RUN mkdir -p $OODT_CONFIG/ecostress
COPY filemgr_config/policy/ $OODT_CONFIG/ecostress/policy/

# create final OODT archive directory
RUN mkdir -p  $OODT_ARCHIVE/ecostress

# install custom OODT Workflow Manager configuration
COPY wmgr_config/policy/ $OODT_CONFIG/ecostress/policy/
COPY wmgr_config/pge-configs/ $OODT_CONFIG/ecostress/pge-configs/

# install custom PGEs
RUN mkdir -p $PGE_ROOT/ecostress/
COPY wmgr_config/pges/ $PGE_ROOT/ecostress/

# FIXME: install custom scripts to start/stop workflow manager and rabbitmq clients
COPY scripts/ /usr/local/bin/

VOLUME $OODT_CONFIG
VOLUME $PGE_ROOT
VOLUME $OODT_ARCHIVE
VOLUME /usr/local/bin
