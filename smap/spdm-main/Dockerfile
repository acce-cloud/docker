# Docker image for SMAP SPDM installation. Includes:

FROM oodthub/oodt-node

#
# Usage:
# docker build -t oodthub/spdm-services \
#		--build-arg jpl_git_user=${JPL_GIT_USER} \
#        	--build-arg jpl_git_token=${JPL_GIT_TOKEN} \
#
# Required arguments
#
ARG jpl_git_user=
ARG jpl_git_token=
#
# install sqlplus
#
COPY build/apps/oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm /tmp/.
COPY build/apps/oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.rpm /tmp/.
# 
RUN yum -y install libaio
RUN cd /tmp; rpm -ivh oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm
RUN cd /tmp; rpm -ivh oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.rpm
#
# install tree command
RUN yum -y install tree
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
ENV SPDM_BIN $SPDM_HOME/spdm-main/bin
ENV SPDM_BUILD /usr/local/spdm/build
#
# default SPDM runtime environment
#
RUN mkdir -p $SPDM_HOME
RUN mkdir -p $SPDM_BUILD
#
#-- replaced begin
# compile & deploy SPDM with test profile
#
#RUN cd $SPDM_BUILD; curl -fsSL --user ${jpl_git_user}:${jpl_git_token} https://github.jpl.nasa.gov/SPDM/spdm/archive/${SPDM_VERSION}.tar.gz | tar -xvz
#COPY build/spdm.properties ${SPDM_BUILD}/spdm-${SPDM_VERSION}
#RUN cd ${SPDM_BUILD}/spdm-${SPDM_VERSION}; mvn install -Pspdm-dev -Dmaven.test.skip=true
#
# distrubte SPDM
#
#RUN cd $SPDM_BUILD/spdm-${SPDM_VERSION}; tar xvfz spdm-distribution/target/spdm-distribution-${SPDM_VERSION}-dist.tar.gz
#
# replaced end --
## replaced with begin
#RUN mkdir -p $SPDM_BUILD/spdm-${SPDM_VERSION}
#COPY build/apps/spdm-distribution-${SPDM_VERSION}-dist.tar.gz $SPDM_BUILD/spdm-${SPDM_VERSION}/.
#RUN cd $SPDM_BUILD/spdm-${SPDM_VERSION}; tar xvfz spdm-distribution-${SPDM_VERSION}-dist.tar.gz
RUN mkdir -p $SPDM_BUILD/spdm-${SPDM_VERSION}/spdm-distribution-${SPDM_VERSION}
COPY build/apps/spdm-distribution-${SPDM_VERSION}/ $SPDM_BUILD/spdm-${SPDM_VERSION}/spdm-distribution-${SPDM_VERSION}/
#
## replaced with end
#
RUN cd $SPDM_BUILD/spdm-${SPDM_VERSION}/spdm-distribution-${SPDM_VERSION}; sh install.sh
#
# build directory structures required for spdm operation
#
COPY build/setupSPDMdir.sh ${SPDM_BUILD}/.
RUN cd ${SPDM_BUILD}; sh setupSPDMdir.sh
RUN cd $SPDM_BUILD/spdm-${SPDM_VERSION}/spdm-distribution-${SPDM_VERSION}; sh configure.sh
# 
# patch test scripts with your test environment
#
RUN cd ${SPDM_HOME}/spdm-pge/conf/L01_Radar; mv L1C_S0_HiRes_PgeConfig.xml L1C_S0_HiRes_PgeConfig.xml.orig
COPY config/test/L1C_S0_HiRes_PgeConfig.xml ${SPDM_HOME}/spdm-pge/conf/L01_Radar/.
RUN cd ${SPDM_HOME}/spdm-main/bin/test/regression; mv regression_testSetup.sh regression_testSetup.sh.orig
COPY config/test/regression_testSetup.sh ${SPDM_HOME}/spdm-main/bin/test/regression/.
COPY config/nodes.xml ${SPDM_HOME}/spdm-resource/policy/dev/.
COPY config/node-to-queue-mapping.xml ${SPDM_HOME}/spdm-resource/policy/dev/.
COPY config/distribution.properties ${SPDM_HOME}/spdm-sips/etc/.
#
# Retart services automatically
#
COPY scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
#
# copy scripts to setup configuration when container is created and started
#
COPY build/upd_setenv.sh ${SPDM_BUILD}/.
COPY config/setenv.sh ${SPDM_BUILD}/.
COPY build/setupSPDMDB.sh ${SPDM_BUILD}/.
CMD ["/usr/local/bin/docker-entrypoint.sh"]
