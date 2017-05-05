#!/bin/sh
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
sh ${SPDM_HOME}/spdm-resource/bin/stub_startup.sh ${SPDM_HOME} `hostname`
tail -f /dev/null
