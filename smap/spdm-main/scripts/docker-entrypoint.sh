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
# define $SPDM_COMPONENTS when starting docker service
#for service in filemgr resource workflow all-crawler all-batchstub
for service in ${SPDM_COMPONENTS}
do 
	sh spdm_startup.sh ${service}
done
if [[ ! -z "${PGE_WORKFLOWMGR_URL}" ]] ; then
   cd ${SPDM_HOME}/spdm-pge/conf
   ORIGFILE=./PgeCommonMetadata.xml
   NEWFILE=./PgeCommonMetadata.xml.new
   sed 's/WORKFLOWMGR_URL/PGE_WORKFLOWMGR_URL/g' ${ORIGFILE} > ${NEWFILE}
   mv ${ORIGFILE} ${ORIGFILE}.orig
   mv ${NEWFILE} ${ORIGFILE}
fi
#
tail -f /dev/null
