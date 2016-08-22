# Docker image for running the 'test-workflow' in a docker-compose environment.
# This image can be used to add custom configuration onto existing File Manager and Workflow Manager services.
#
# Note: this image extends the core oodthub/oodt-node (which has no OODT services installed).
# Note: the published files will be of product type "TestFile".

FROM oodthub/oodt-node

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# install custom OODT File Manager configuration
RUN mkdir -p $OODT_CONFIG/test-workflow
COPY filemgr_config/policy/ $OODT_CONFIG/test-workflow/policy/

# create final OODT archive directory
RUN mkdir -p  $OODT_ARCHIVE/test-workflow

# install custom OODT Workflow Manager configuration
COPY wmgr_config/policy/ $OODT_CONFIG/test-workflow/policy/
COPY wmgr_config/pge-configs/ $OODT_CONFIG/test-workflow/pge-configs/

# install custom PGEs
RUN mkdir -p $PGE_ROOT/test-workflow
COPY pges/ $PGE_ROOT/test-workflow/

VOLUME $OODT_CONFIG
VOLUME $PGE_ROOT
VOLUME $OODT_ARCHIVE
