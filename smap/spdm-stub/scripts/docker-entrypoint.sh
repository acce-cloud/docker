#!/bin/sh
cd ${SPDM_HOME}/spdm-main/bin
#
sh spdm_shutdown.sh all-batchstub
#
# Ensure to start batchstub
#
for service in all-batchstub
do 
   sh spdm_startup.sh ${service}
done
tail -f /dev/null
