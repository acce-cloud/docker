# Docker image that contains configuration for running the OODT test-workflow in a Docker swarm.
# This image contains an OODT Workflow Manager configured with a custom 'test-workflow'. 
# It publishes products of type "GenericFile", so that no custom configuration of the OODT File Manager is required.
#
# Note: this image extends oodthub/oodt-wmgr, which contains the OODT Workflow Manager and Crawler.


FROM oodthub/oodt-wmgr

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# OODT env
ENV OODT_HOME /usr/local/oodt
ENV OODT_SITE_DIR ${OODT_SITE_DIR:-${OODT_HOME}/mysite}

# install custom OODT Workflow Manager configuration
RUN mkdir -p $OODT_SITE_DIR/workflows/test-workflow
COPY wmgr_config/policy/ $OODT_SITE_DIR/workflows/test-workflow/policy/
COPY wmgr_config/pge-configs/ $OODT_SITE_DIR/workflows/test-workflow/pge-configs/

# install custom PGEs
RUN mkdir -p $OODT_SITE_DIR/pges/test-workflow
COPY pges/ $OODT_SITE_DIR/pges/test-workflow/

VOLUME $OODT_SITE_DIR

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord-workflow.conf"]
