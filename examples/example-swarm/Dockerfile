# Docker image that contains configuration for running the OODT test-workflow in a Docker swarm.
# This image contains an OODT Workflow Manager configured with a custom 'test-workflow'. 
# It publishes products of type "GenericFile", so that no custom configuration of the OODT File Manager is required.
#
# Note: this image extends oodthub/oodt-wmgr, which contains the OODT Workflow Manager and Crawler.


FROM oodthub/oodt-wmgr

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# install custom OODT Workflow Manager configuration
RUN mkdir -p $OODT_CONFIG/test-workflow
COPY wmgr_config/policy/ $OODT_CONFIG/test-workflow/policy/
COPY wmgr_config/pge-configs/ $OODT_CONFIG/test-workflow/pge-configs/

# install custom PGEs
RUN mkdir -p $PGE_ROOT/test-workflow
COPY pges/ $PGE_ROOT/test-workflow/

VOLUME $OODT_CONFIG

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord-workflow.conf"]
