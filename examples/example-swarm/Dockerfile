# Docker image that contains the specific configuration and executables
# for running the OODT test workflow.

# Note: this workflow produces products of type 'GenericFile' 
# so no custom File Manager policy is installed.

FROM oodthub/oodt-node

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# install custom OODT File Manager configuration
#RUN mkdir -p $OODT_CONFIG/test-workflow
#COPY filemgr_config/policy/ $OODT_CONFIG/test-workflow/policy/

# create final OODT archive directory
RUN mkdir -p  $OODT_ARCHIVE/test-workflow

# install custom OODT Workflow Manager configuration
RUN mkdir -p $OODT_CONFIG/test-workflow
COPY wmgr_config/ $OODT_CONFIG/test-workflow/

# install custom PGEs
RUN mkdir -p $PGE_ROOT/test-workflow
COPY pges/ $PGE_ROOT/test-workflow/

VOLUME $OODT_CONFIG
VOLUME $PGE_ROOT
VOLUME $OODT_ARCHIVE
