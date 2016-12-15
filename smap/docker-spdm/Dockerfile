# Docker image for SMAP SPDM installation. Includes:

FROM oodthub/oodt-node

#
# install sqlplus
#
COPY oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm /tmp/.
COPY oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.rpm /tmp/.
# 
RUN yum -y install libaio
RUN cd /tmp; rpm -ivh oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm
RUN cd /tmp; rpm -ivh oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.rpm
#
ENV ORACLE_HOME /usr/lib/oracle/12.1/client64
ENV LD_LIBRARY_PATH /usr/lib/oracle/12.1/client64/lib:${LD_LIBRARY_PATH}
ENV PATH /usr/lib/oracle/12.1/client64/bin:${PATH}
#
#####
#
# default SPDM build environment
#
ENV SPDM_VERSION 1.4.2
ENV SPDM_HOME /usr/local/spdm/deploy
ENV SPDM_BUILD /usr/local/spdm/build
#
# default SPDM runtime environment
#
RUN mkdir -p $SPDM_HOME
RUN mkdir -p $SPDM_BUILD
#
# compile SPDM
#
RUN cd $SPDM_BUILD; curl -fsSL --user clwong:7864d53965defcc7332335ea3fe9699f0acebe22 https://github.jpl.nasa.gov/SPDM/spdm/archive/${SPDM_VERSION}.tar.gz | tar -xvz
COPY spdm.properties ${SPDM_BUILD}/spdm-${SPDM_VERSION}
RUN cd ${SPDM_BUILD}/spdm-${SPDM_VERSION}; mvn install -Pspdm-dev -Dmaven.test.skip=true
#
# distrubte SPDM
#
RUN cd $SPDM_BUILD/spdm-${SPDM_VERSION}; tar xvfz spdm-distribution/target/spdm-distribution-${SPDM_VERSION}-dist.tar.gz
RUN cd $SPDM_BUILD/spdm-${SPDM_VERSION}/spdm-distribution-${SPDM_VERSION}; sh install.sh
#
# setup & configure SPDM with pre-set property file, setenv.sh
#
RUN cd ${SPDM_HOME}/spdm-main/bin; mv setenv.sh setenv.sh.orig
COPY setenv.sh ${SPDM_HOME}/spdm-main/bin/.
COPY setupSPDMdir.sh ${SPDM_BUILD}/.
RUN cd ${SPDM_BUILD}; sh setupSPDMdir.sh
RUN cd $SPDM_BUILD/spdm-${SPDM_VERSION}/spdm-distribution-${SPDM_VERSION}; sh configure.sh
#
# Retart services automatically
#
RUN cd ${SPDM_HOME}/spdm-main/bin; sh spdm_shutdown.sh all
RUN cd ${SPDM_HOME}/spdm-main/bin; for service in filemgr resource workflow all-crawler ; do sh spdm_startup.sh ${service}; done
