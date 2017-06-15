#!/bin/sh
# setup configuration
#
echo ${DB_HOST} ${DB_PORT} ${DB_INSTANT} ${DB_USER} ${DB_PASS}
cd ${SPDM_BUILD}; sh upd_setenv.sh ${DB_HOST} ${DB_PORT} ${DB_INSTANT} ${DB_USER} ${DB_PASS}
cp -p ${SPDM_BUILD}/setenv.sh ${SPDM_HOME}/spdm-main/bin/.
cp -p ${SPDM_BUILD}/setenv.sh ${SPDM_HOME}/spdm-filemgr/bin/.
#
#cd ${SPDM_HOME}/spdm-main/bin
#
#sh spdm_shutdown.sh all-batchstub
#
# Ensure to start batchstub
#
#for service in all-batchstub
#do 
#   sh spdm_startup.sh ${service}
#done
echo "Execute ${SPDM_HOME}/spdm-resource/bin/stub_startup.sh"
#sh ${SPDM_HOME}/spdm-resource/bin/stub_startup.sh ${SPDM_HOME} `hostname`

HOST=`hostname`
IP=`nslookup ${HOST} | awk '/^Address: / { print $2 }'`

sh ${SPDM_HOME}/spdm-resource/bin/stub_startup.sh ${SPDM_HOME} ${IP}
tail -f /dev/null
