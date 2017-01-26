#!/bin/sh
cd ${SPDM_HOME}/spdm-main/bin
#
sh spdm_shutdown.sh all
#
# Ensure to start resource manager before workflow manager
#
for service in filemgr resource workflow all-crawler all-batchstub
do 
	sh spdm_startup.sh ${service}
done
tail -f /dev/null
