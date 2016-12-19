#!/bin/sh
#   @author clwong
#
# This script setup SPDM initial directory layout automatically based on setenv.sh
#
# Normally, the directory layout will have to coordinate with 
# System Administrator  & System Engineer
#
if [ -z $SPDM_HOME ] ; then
   echo "Please setenv SPDM_HOME"
   exit 1
fi
## override environment variables defined in setenv.sh if there is one
if [ -r $SPDM_HOME/spdm-main/bin/setenv.sh ]; then
   . $SPDM_HOME/spdm-main/bin/setenv.sh
fi

echo "Checking & making SPDM required directory layout..."
for dir in ${SDS_HOME} ${LOM_HOME} ${SPDM_WORKSPACE} \
        ${ANALYSIS_HOME} ${FAILED_TASK_HOME} ${REPORT_HOME} \
        ${PID_HOME} ${WORKFLOW_LUCENE_HOME} \
        ${CRAWLER_SUCCESS_DIR} ${CRAWLER_FAILURE_DIR} \
        ${GDS_CRAWLER_PATH} ${L1_EXT_CRAWLER_PATH} \
        ${ANTAZ_CRAWLER_PATH} \ ${L2PP_CRAWLER_PATH} \
        ${STUF_CRAWLER_PATH} \ ${RADAR_L0A_CRAWLER_PATH} \
        ${RADIOMETER_L0A_CRAWLER_PATH} ${GENERAL_CRAWLER_PATH} \
        ${LUT_HISTORY_CRAWLER_PATH} \
        ${ASF_INTERNAL_PATH}/data ${L4_INTERNAL_PATH}/data ${NSIDC_INTERNAL_PATH}/data \
        ${ASF_INTERNAL_PATH}/PAN ${L4_INTERNAL_PATH}/PAN ${NSIDC_INTERNAL_PATH}/PAN \
        ${ASF_INTERNAL_PATH}/PDRD ${L4_INTERNAL_PATH}/PDRD ${NSIDC_INTERNAL_PATH}/PDRD \
        ${SPDM_LOG_HOME}
do
   if [ ! -d ${dir} ]; then
      echo "Directory ${dir} not found!"
      mkdir -p ${dir}
   fi
done

