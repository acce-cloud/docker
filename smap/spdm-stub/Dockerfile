# Docker image for SMAP SPDM installation. Includes:

FROM oodthub/spdm-services:0.3

MAINTAINER Cynthia L. Wong <cynthia.l.wong@jpl.nasa.gov>
#
# update setenv.sh SPDM_HOST
#
COPY build/upd_setenv_host.sh ${SPDM_BUILD}/.
RUN cd ${SPDM_BUILD}; sh upd_setenv_host.sh
RUN cp -p ${SPDM_BUILD}/setenv.sh ${SPDM_HOME}/spdm-main/bin/.
RUN cp -p ${SPDM_BUILD}/setenv.sh ${SPDM_HOME}/spdm-filemgr/bin/.
#
# start stubs automatically
#
COPY scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
CMD ["/usr/local/bin/docker-entrypoint.sh"]
