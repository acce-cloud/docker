#!/bin/sh
# Copyright (c) 2009-2015 California Institute of Technology.
# ALL RIGHTS RESERVED. U.S. Government Sponsorship acknowledged.
#
#   @author clwong
#   $Id$
#
# This script configures spdm properties based on setenv.sh
# Will need write permission to SPDM deployment areas
#
if [ -z $SPDM_HOME ] ; then
   echo "Please setenv SPDM_HOME"
   exit 1
fi
## override environment variables defined in setenv.sh if there is one
if [ -r $SPDM_HOME/spdm-main/bin/setenv.sh ]; then
   . $SPDM_HOME/spdm-main/bin/setenv.sh
fi

# Find SDS directory layout
# Find SPDM working directory layout
echo "Checking SPDM required directory layout..."
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
   fi
done

if [ -z ${FILEMGR_DB_USER} ] || [ -z ${FILEMGR_DB_PASS} ] ; then
   echo "FILEMGR_DB_USER or FILEMGR_DB_PASS are not set!"
fi

# Update $SPDM_HOME/spdm-ws/WEB-INF/web.xml
echo "Updating $SPDM_HOME/spdm-ws/WEB-INF/web.xml" 
cp -pr $SPDM_HOME/spdm-ws/WEB-INF/web.xml $SPDM_HOME/spdm-ws/WEB-INF/web.xml.orig

for i in $SPDM_HOME/spdm-ws/WEB-INF/web.xml*
do
    sed 's#${filemgr_url}#'${FILEMGR_URL}'#' $i > $i.tmp; mv $i.tmp $i
    sed 's#${workflowmgr_url}#'${WORKFLOWMGR_URL}'#' $i > $i.tmp; mv $i.tmp $i
    sed 's#${resourcemgr_url}#'${RESOURCEMGR_URL}'#' $i > $i.tmp; mv $i.tmp $i
    sed 's#${db_instant}#'${DB_INSTANT}'#' $i > $i.tmp; mv $i.tmp $i
    sed 's#${spdm_home}#'${SPDM_HOME}'#' $i > $i.tmp; mv $i.tmp $i
    sed 's#${spdm_log_home}#'${SPDM_LOG_HOME}'#' $i > $i.tmp; mv $i.tmp $i
    sed 's#${webserver_url}#'${WEBSERVER_URLS}'#' $i > $i.tmp; mv $i.tmp $i
done

# Update Tomcat Web Server Host
echo "Updating ${SPDM_HOME}/spdm-webapp/spdm/config.ini"
cp -pr ${SPDM_HOME}/spdm-webapp/spdm/config.ini ${SPDM_HOME}/spdm-webapp/spdm/config.ini.orig

sed 's#${spdm_ws_url}#'${SPDM_WS_URL}'#' ${SPDM_HOME}/spdm-webapp/spdm/config.ini > ${SPDM_HOME}/spdm-webapp/spdm/config.ini.tmp
mv ${SPDM_HOME}/spdm-webapp/spdm/config.ini.tmp ${SPDM_HOME}/spdm-webapp/spdm/config.ini

# Update $CRAWLER_HOME/policy/spdm-crawlers.xml to support SPDM Web Services Configuration
echo "Updating $CRAWLER_HOME/policy/spdm-crawlers.xml"
cp -pr $CRAWLER_HOME/policy/spdm-crawlers.xml $CRAWLER_HOME/policy/spdm-crawlers.xml.orig

upd_crawler_port () {
   oldport=$1
   port=$2
   sed 's#'$oldport'#'$port'#' $CRAWLER_HOME/policy/spdm-crawlers.xml > $CRAWLER_HOME/policy/spdm-crawlers.xml.tmp
   mv $CRAWLER_HOME/policy/spdm-crawlers.xml.tmp $CRAWLER_HOME/policy/spdm-crawlers.xml
}

upd_crawler_port 9010 $GDS_CRAWLER_DAEMON_PORT
upd_crawler_port 9011 $L1_EXT_CRAWLER_DAEMON_PORT
upd_crawler_port 9012 $ANTAZ_CRAWLER_DAEMON_PORT
upd_crawler_port 9013 $L2PP_CRAWLER_DAEMON_PORT
upd_crawler_port 9014 $STUF_CRAWLER_DAEMON_PORT
upd_crawler_port 9015 $RADAR_L0A_CRAWLER_DAEMON_PORT
upd_crawler_port 9016 $RADIOMETER_L0A_CRAWLER_DAEMON_PORT
upd_crawler_port 9017 $GENERAL_CRAWLER_DAEMON_PORT
upd_crawler_port 9018 $LUT_HISTORY_CRAWLER_DAEMON_PORT
upd_crawler_port 9020 $ASF_PAN_CRAWLER_DAEMON_PORT
upd_crawler_port 9021 $NSIDC_PAN_CRAWLER_DAEMON_PORT
upd_crawler_port 9022 $L4_PAN_CRAWLER_DAEMON_PORT
upd_crawler_port 9023 $ASF_PDRD_CRAWLER_DAEMON_PORT
upd_crawler_port 9024 $NSIDC_PDRD_CRAWLER_DAEMON_PORT
upd_crawler_port 9025 $L4_PDRD_CRAWLER_DAEMON_PORT

sed 's#${spdm_host}#'${SPDM_HOST}'#' $CRAWLER_HOME/policy/spdm-crawlers.xml > $CRAWLER_HOME/policy/spdm-crawlers.tmp
mv $CRAWLER_HOME/policy/spdm-crawlers.tmp $CRAWLER_HOME/policy/spdm-crawlers.xml
