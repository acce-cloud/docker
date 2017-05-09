#!/bin/sh
#
# setup configuration
#
echo ${DB_HOST} ${DB_PORT} ${DB_INSTANT} ${DB_USER} ${DB_PASS}
cd ${SPDM_BUILD}; sh upd_setenv.sh ${DB_HOST} ${DB_PORT} ${DB_INSTANT} ${DB_USER} ${DB_PASS}
cp -p ${SPDM_BUILD}/setenv.sh ${SPDM_HOME}/spdm-main/bin/.
cp -p ${SPDM_BUILD}/setenv.sh ${SPDM_HOME}/spdm-filemgr/bin/.
#
cd ${SPDM_HOME}/spdm-main/bin
#
sh spdm_shutdown.sh all
#
# Ensure to start resource manager before workflow manager
#
#for service in filemgr resource workflow all-crawler all-batchstub
for service in filemgr resource workflow all-crawler 
do 
	sh spdm_startup.sh ${service}
done
tail -f /dev/null
