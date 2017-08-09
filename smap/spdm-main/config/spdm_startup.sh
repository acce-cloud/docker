#!/bin/sh
# Copyright (c) 2009-2015 California Institute of Technology.
# ALL RIGHTS RESERVED. U.S. Government Sponsorship acknowledged.
#
#   @author clwong
#   $Id$
#
# This script starts all SPDM services in the following order
#   File Manager Server
#   Resource Manager Server
#   Batch Stubs on each node listed in nodes.xml
#   Workflow Manager Server
#   Crawlers
#   Timers
#
# For help,
# 	Usage: $0 help

if [ -z $SPDM_HOME ] ; then
   echo "Please setenv SPDM_HOME"
   exit 1
fi
if [ -z $JAVA_HOME ] ; then
	JAVA_HOME=/pkg/java
else
	JAVA_HOME=${JAVA_HOME}
fi
## override environment variables defined in setenv.sh if there is one
if [ -r ./setenv.sh ]; then
   . ./setenv.sh
fi

# Find SDS directory layout
# Find SPDM working directory layout
dirNotFound=0
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
      dirNotFound=1
   fi
done

if [ ${dirNotFound} != 0 ] ; then
   echo "Exiting..."
   exit 1
fi

if [ -z ${FILEMGR_DB_USER} ] || [ -z ${FILEMGR_DB_PASS} ] ; then
   echo "FILEMGR_DB_USER or FILEMGR_DB_PASS are not set!"
   echo "Exiting..."
   exit 1
fi

#export JAVA_CMD="${JAVA_HOME}/bin/java -Xmx1024M -Xms64M -XX:MaxPermSize=128M"
export JAVA_CMD="${JAVA_HOME}/bin/java -Xmx2048M"

case "$1" in
	help)
		echo "To startup services except for timer"
		echo "	Usage: $0 all"
		echo "To startup services including timer"
		echo "	Usage: $0 all-service"
		echo "To start individual component"
		echo "	Usage: $0 {filemgr | resource | all-batchstub | workflow | all-crawler | timer}"
		echo "To startup individual crawler"
		echo "	Usage: $0 crawler {radar-L0A | radiom-L0A | stuf | gds | l1_ext | antaz | l2pp | asf-pdrd | asf-pan | nsidc-pdrd | nsidc-pan | l4-pdrd | l4-pan | general | lut_history}"
		echo "To startup individual batch stub"
		echo "	Usage: $0 batchstub {nodename}"
		;;
	filemgr)
        sh ${SPDM_HOME}/spdm-main/bin/spdm_status.sh filemgr
		if [ -f ${PID_HOME}/spdm-filemgr.pid ] ; then
            echo "File Manager is already running."
        else
			export FILEMGR_HOME=${SPDM_HOME}/spdm-filemgr
			echo "Starting file manager... "
			${JAVA_CMD} \
	        	-Djava.ext.dirs=${FILEMGR_HOME}/lib \
	        	-Djava.util.logging.config.file=${FILEMGR_HOME}/etc/logging.properties \
	    	    	-Dorg.apache.oodt.cas.filemgr.properties=${FILEMGR_HOME}/etc/filemgr.properties \
	        	gov.nasa.smap.spdm.filemgr.system.SpdmFileManager \
	        	--portNum ${FILEMGR_PORT} &
	        	echo $! > ${PID_HOME}/spdm-filemgr.pid
			echo "File manager started."
	        	sleep 25
                fi
		;;
	resource)
        sh ${SPDM_HOME}/spdm-main/bin/spdm_status.sh resource
		if [ -f ${PID_HOME}/spdm-resource.pid ] ; then
            echo "Resource Manager is already running."
        else
			export RESOURCEMGR_HOME=${SPDM_HOME}/spdm-resource
			echo "Starting resource manager... "
	        ${JAVA_CMD} \
			-Djava.ext.dirs=${RESOURCEMGR_HOME}/lib \
	        	-Djavax.xml.transform.TransformerFactory=net.sf.saxon.TransformerFactoryImpl \
	        	-Djava.util.logging.config.file=${RESOURCEMGR_HOME}/etc/logging.properties \
	        	-Dgov.nasa.smap.spdm.resource.properties=${RESOURCEMGR_HOME}/etc/resource.properties \
	        	gov.nasa.smap.spdm.resource.system.SmapXmlRpcResourceManager \
	        	--portNum ${RESOURCEMGR_PORT} &
	        	echo $! > ${PID_HOME}/spdm-resource.pid
			echo "Resource manager started."
	        	sleep 5
		fi
		;;
	batchstub)
		if [ $# -eq 2 ] ; then
			node=$2
			python ${RESOURCEMGR_HOME}/bin/startstop_stubs_on_nodes.py \
				${RESOURCEMGR_HOME}/policy/${RESOURCE_VENUE}/nodes.xml start $node
		else
			echo "To startup individual batch stub"
			echo "	Usage: $0 batchstub {nodename}"
	    fi
        ;;
    all-batchstub)
		python ${RESOURCEMGR_HOME}/bin/startstop_stubs_on_nodes.py \
	            ${RESOURCEMGR_HOME}/policy/${RESOURCE_VENUE}/nodes.xml clean
	    sleep 5
	    python ${RESOURCEMGR_HOME}/bin/startstop_stubs_on_nodes.py \
	            ${RESOURCEMGR_HOME}/policy/${RESOURCE_VENUE}/nodes.xml start
    	;;
	workflow)
        sh ${SPDM_HOME}/spdm-main/bin/spdm_status.sh workflow
		if [ -f ${PID_HOME}/spdm-workflow.pid ] ; then
            echo "Workflow Manager is already running."
        else
			export WORKFLOWMGR_HOME=${SPDM_HOME}/spdm-workflow
			export STAGING_AREA=${SPDM_WORKSPACE}
#>>>
# if RESOURCEMGR_URL not set or empty, RM server is not used
# then don't check
#
                if [[ ! -z "${RESOURCEMGR_URL}" ]] ; then
                        echo "Checking if all queues defined in the Workflow Manager policy are defined in the Resource Manager policy ..."
                        sh ${SPDM_HOME}/spdm-main/bin/spdm_admin.sh --validateQueues
                fi
#<<<
			if [ $? != 0 ] ; then
			    echo "Will not start Workflow Manager due to undefined queues in the Resource Manager policy"
			else
#>>>
# add subdirectory under SPDM_LOG_HOME	
#
		ORIGFILE=${WORKFLOWMGR_HOME}/etc/logging.properties
		NEWFILE=${WORKFLOWMGR_HOME}/etc/logging.properties.new
		sed 's#'${SPDM_LOG_HOME}'#'${SPDM_LOG_HOME}'/'${HOSTNAME}'#' ${ORIGFILE} > ${NEWFILE}
                mv ${ORIGFILE} ${ORIGFILE}.orig
                mv ${NEWFILE} ${ORIGFILE}
#<<<
    			echo "Starting workflow manager..."
    	        ${JAVA_CMD} -Djava.ext.dirs=${WORKFLOWMGR_HOME}/lib \
    	        	-Djava.util.logging.config.file=${WORKFLOWMGR_HOME}/etc/logging.properties \
    	        	-Dorg.apache.oodt.cas.workflow.properties=${WORKFLOWMGR_HOME}/etc/workflow.properties \
    	        	gov.nasa.smap.spdm.workflow.system.XmlRpcWorkflowManager \
    	        	--portNum ${WORKFLOWMGR_PORT} &
    	        echo $! >${PID_HOME}/spdm-workflow.pid
    			echo "Workflow manager started."
    	        sleep 10
    	        if [ -f ${PID_HOME}/spdm-filemgr.pid ] ; then
    # SPDM-453 automated cleanup of non-existing workflows after WM was interrupted.
    # Require both FM & WM running
    	        	echo "Cleaning up the non-existing workflows (not in Lucene/index) ..."
    	        	echo "Require File and Workflow managers running"
    	        	echo "Executing automatically sh spdm_admin.sh --killAllNonExistentWFInsts ..."
    	        	sh ${SPDM_HOME}/spdm-main/bin/spdm_admin.sh --killAllNonExistentWFInsts
    	        fi
    	    fi
		fi
		;;
	crawler)
        case "$2" in
            radar-L0A)
                sh ${SPDM_HOME}/spdm-main/bin/spdm_status.sh crawler $2
                if [ -f ${PID_HOME}/radar-L0A-crawler.pid ] ; then
                    echo "Radar L0A file crawler is already running."
                else
                    export PRECONDITIONS="CheckRadarFileExistence CheckSignalFileExistence"
                    export ACTIONS="Unique FileSizeGreaterThanZero KickoffRadarPipelineWorkflow DeleteDataFile DeleteSignalFile MoveDownlinkAndSignalToFailureDir"
                    ${JAVA_CMD} -Djava.ext.dirs=${CRAWLER_HOME}/lib \
                    	-Djava.util.logging.config.file=${CRAWLER_HOME}/etc/$2.logging.properties \
                    	-Dlog4j.configuration=file://${SPDM_HOME}/spdm-crawler/etc/log4j.properties \
                        -Dorg.apache.oodt.cas.crawl.bean.repo=file://${CRAWLER_HOME}/policy/crawler-config.xml \
                        gov.nasa.smap.spdm.crawl.SpdmCrawlerLauncher \
                        -cid SpdmNoMetCrawler -fm ${FILEMGR_URL} -pids ${PRECONDITIONS} -ais ${ACTIONS} \
                        -sd ${CRAWLER_SUCCESS_DIR} \
                        -fd ${CRAWLER_FAILURE_DIR} \
                        -ct gov.nasa.smap.spdm.filemgr.datatransfer.SpdmLocalDataTransferFactory \
                        -mx gov.nasa.smap.spdm.crawl.metadata.extractor.DownlinkProdMetExtractor \
                        --daemonPort ${RADAR_L0A_CRAWLER_DAEMON_PORT} --daemonWait ${RADAR_L0A_CRAWLER_WAIT} \
                        -pp ${RADAR_L0A_CRAWLER_PATH} ${RADAR_L0A_CRAWLER_NR} &
                    echo $! >${PID_HOME}/radar-L0A-crawler.pid
                    echo "Radar L0A file crawler started."
                fi
                ;;
            radiom-L0A)
                sh ${SPDM_HOME}/spdm-main/bin/spdm_status.sh crawler $2
                if [ -f ${PID_HOME}/radiom-L0A-crawler.pid ] ; then
                    echo "Radiometer L0A file crawler is already running."
                else
                    export PRECONDITIONS="CheckRadiometerFileExistence CheckSignalFileExistence"
                    export ACTIONS="Unique FileSizeGreaterThanZero KickoffRadiometerPipelineWorkflow DeleteDataFile DeleteSignalFile MoveDownlinkAndSignalToFailureDir"
                    ${JAVA_CMD} -Djava.ext.dirs=${CRAWLER_HOME}/lib \
		             	-Djava.util.logging.config.file=${CRAWLER_HOME}/etc/$2.logging.properties \
                    	-Dlog4j.configuration=file://${SPDM_HOME}/spdm-crawler/etc/log4j.properties \
                        -Dorg.apache.oodt.cas.crawl.bean.repo=file://${CRAWLER_HOME}/policy/crawler-config.xml \
                        gov.nasa.smap.spdm.crawl.SpdmCrawlerLauncher \
                        -cid SpdmNoMetCrawler -fm ${FILEMGR_URL} -pids ${PRECONDITIONS} -ais ${ACTIONS} \
                        -sd ${CRAWLER_SUCCESS_DIR} \
                        -fd ${CRAWLER_FAILURE_DIR} \
                        -ct gov.nasa.smap.spdm.filemgr.datatransfer.SpdmLocalDataTransferFactory \
                        -mx gov.nasa.smap.spdm.crawl.metadata.extractor.DownlinkProdMetExtractor \
                        --daemonPort ${RADIOMETER_L0A_CRAWLER_DAEMON_PORT} --daemonWait ${RADIOMETER_L0A_CRAWLER_WAIT} \
                        -pp ${RADIOMETER_L0A_CRAWLER_PATH} ${RADIOMETER_L0A_CRAWLER_NR} &
                    echo $! >${PID_HOME}/radiom-L0A-crawler.pid
                    echo "Radiometer L0A file crawler started."
                fi
                ;;
            stuf)
                sh ${SPDM_HOME}/spdm-main/bin/spdm_status.sh crawler $2
                if [ -f ${PID_HOME}/stuf-crawler.pid ] ; then
                    echo "STUF file crawler is already running."
                else
                    export PRECONDITIONS="CheckStufFileExistence CheckSignalFileExistence"
                    export ACTIONS="Unique FileSizeGreaterThanZero DeleteDataFile DeleteSignalFile MoveDataFileToFailureDir MoveSignalFileToFailureDir"
                    ${JAVA_CMD} -Djava.ext.dirs=${CRAWLER_HOME}/lib \
                        -Djava.util.logging.config.file=${CRAWLER_HOME}/etc/$2.logging.properties \
                    	-Dlog4j.configuration=file://${SPDM_HOME}/spdm-crawler/etc/log4j.properties \
                        -Dorg.apache.oodt.cas.crawl.bean.repo=file://${CRAWLER_HOME}/policy/crawler-config.xml \
                        gov.nasa.smap.spdm.crawl.SpdmCrawlerLauncher \
                        -cid SpdmNoMetCrawler -fm ${FILEMGR_URL} -pids ${PRECONDITIONS} -ais ${ACTIONS} \
                        -sd ${CRAWLER_SUCCESS_DIR} \
                        -fd ${CRAWLER_FAILURE_DIR} \
                        -ct gov.nasa.smap.spdm.filemgr.datatransfer.SpdmLocalDataTransferFactory \
                        -mx gov.nasa.smap.spdm.crawl.metadata.extractor.StufProductMetExtractor \
                        --daemonPort ${STUF_CRAWLER_DAEMON_PORT} --daemonWait ${STUF_CRAWLER_WAIT} \
                        -pp ${STUF_CRAWLER_PATH} ${STUF_CRAWLER_NR} &
                    echo $! >${PID_HOME}/stuf-crawler.pid
                    echo "STUF file crawler started."
                fi
                ;;
            gds)
                sh ${SPDM_HOME}/spdm-main/bin/spdm_status.sh crawler $2
                if [ -f ${PID_HOME}/gds-crawler.pid ] ; then
                    echo "GDS file crawler is already running."
                else
                    export ACTIONS="Unique FileSizeGreaterThanZero DeleteDataFile DeleteSignalFile MoveDataFileToFailureDir MoveSignalFileToFailureDir"
                    ${JAVA_CMD} -Djava.ext.dirs=${CRAWLER_HOME}/lib \
                        -Djava.util.logging.config.file=${CRAWLER_HOME}/etc/$2.logging.properties \
                    	-Dlog4j.configuration=file://${SPDM_HOME}/spdm-crawler/etc/log4j.properties \
                        -Dorg.apache.oodt.cas.crawl.bean.repo=file://${CRAWLER_HOME}/policy/crawler-config.xml \
                        -Dgov.nasa.smap.spdm.crawl.ancillary.map=${CRAWLER_HOME}/policy/ancillary-type-map.xml \
                        gov.nasa.smap.spdm.crawl.SpdmCrawlerLauncher \
                        -cid SpdmAutoDetectProductCrawler -fm ${FILEMGR_URL} -ais ${ACTIONS} \
                        -sd ${CRAWLER_SUCCESS_DIR} \
                        -fd ${CRAWLER_FAILURE_DIR} \
                        -ct gov.nasa.smap.spdm.filemgr.datatransfer.SpdmLocalDataTransferFactory \
                        -mxr ${CRAWLER_HOME}/policy/gds-mime-extractor-map.xml \
                        --daemonPort ${GDS_CRAWLER_DAEMON_PORT} --daemonWait ${GDS_CRAWLER_WAIT} \
                        -pp ${GDS_CRAWLER_PATH} \
                        -ed ${GDS_CRAWLER_EXCLUDE_DIRS} &
                    echo $! >${PID_HOME}/gds-crawler.pid
                    echo "GDS file crawler started."
                fi
                ;;
            l1_ext)
                sh ${SPDM_HOME}/spdm-main/bin/spdm_status.sh crawler $2
                if [ -f ${PID_HOME}/l1_ext-crawler.pid ] ; then
                    echo "L1_EXT file crawler is already running."
                else
                    export ACTIONS="Unique FileSizeGreaterThanZero DeleteDataFile DeleteSignalFile MoveDataFileToFailureDir MoveSignalFileToFailureDir"
                    ${JAVA_CMD} -Djava.ext.dirs=${CRAWLER_HOME}/lib \
                        -Djava.util.logging.config.file=${CRAWLER_HOME}/etc/$2.logging.properties \
                        -Dlog4j.configuration=file://${SPDM_HOME}/spdm-crawler/etc/log4j.properties \
                        -Dorg.apache.oodt.cas.crawl.bean.repo=file://${CRAWLER_HOME}/policy/crawler-config.xml \
                        -Dgov.nasa.smap.spdm.crawl.ancillary.map=${CRAWLER_HOME}/policy/ancillary-type-map.xml \
                        gov.nasa.smap.spdm.crawl.SpdmCrawlerLauncher \
                        -cid SpdmAutoDetectProductCrawler -fm ${FILEMGR_URL} -ais ${ACTIONS} \
                        -sd ${CRAWLER_SUCCESS_DIR} \
                        -fd ${CRAWLER_FAILURE_DIR} \
                        -ct gov.nasa.smap.spdm.filemgr.datatransfer.SpdmLocalDataTransferFactory \
                        -mxr ${CRAWLER_HOME}/policy/l1_ext-mime-extractor-map.xml \
                        --daemonPort ${L1_EXT_CRAWLER_DAEMON_PORT} --daemonWait ${L1_EXT_CRAWLER_WAIT} \
                        -pp ${L1_EXT_CRAWLER_PATH} &
                    echo $! >${PID_HOME}/l1_ext-crawler.pid
                    echo "L1_EXT file crawler started."
                fi
                ;;
            antaz)
                sh ${SPDM_HOME}/spdm-main/bin/spdm_status.sh crawler $2
                if [ -f ${PID_HOME}/antaz-crawler.pid ] ; then
                    echo "ANTAZ file crawler is already running."
                else
                    PRECONDITIONS="CheckAntAZInputFilesExistence CheckSignalFileExistence"
                    ACTIONS="Unique FileSizeGreaterThanZero KickoffAntAZPPWorkflow DeleteDataFile DeleteSignalFile MoveDataFileToFailureDir MoveSignalFileToFailureDir"
                    ${JAVA_CMD} -Djava.ext.dirs=${CRAWLER_HOME}/lib \
                    	-Djava.util.logging.config.file=${CRAWLER_HOME}/etc/$2.logging.properties \
                    	-Dlog4j.configuration=file://${SPDM_HOME}/spdm-crawler/etc/log4j.properties \
                        -Dorg.apache.oodt.cas.crawl.bean.repo=file://${CRAWLER_HOME}/policy/crawler-config.xml \
                        gov.nasa.smap.spdm.crawl.SpdmCrawlerLauncher \
                        -cid SpdmNoMetCrawler -fm ${FILEMGR_URL} -pids ${PRECONDITIONS} -ais ${ACTIONS} \
                        -sd ${CRAWLER_SUCCESS_DIR} \
                        -fd ${CRAWLER_FAILURE_DIR} \
                        -ct gov.nasa.smap.spdm.filemgr.datatransfer.SpdmLocalDataTransferFactory \
                        -mx gov.nasa.smap.spdm.crawl.metadata.extractor.AntAzInputsProductMetExtractor \
                        --daemonPort ${ANTAZ_CRAWLER_DAEMON_PORT} --daemonWait ${ANTAZ_CRAWLER_WAIT} \
                        -pp ${ANTAZ_CRAWLER_PATH} ${ANTAZ_CRAWLER_NR} &
                    echo $! >${PID_HOME}/antaz-crawler.pid
                    echo "ANTAZ file crawler started."
                fi
                ;;
            l2pp)
                sh ${SPDM_HOME}/spdm-main/bin/spdm_status.sh crawler $2
                if [ -f ${PID_HOME}/l2pp-crawler.pid ] ; then
                    echo "L2PP file crawler is already running."
                else
                    ACTIONS="Unique FileSizeGreaterThanZero KickoffSnowPPWorkflow KickoffPrecipPPWorkflow KickoffTSurfPPWorkflow KickoffSentinelPipelineWorkflow DeleteDataFile DeleteSignalFile MoveDataFileToFailureDir MoveSignalFileToFailureDir"
                    ${JAVA_CMD} -Djava.ext.dirs=${CRAWLER_HOME}/lib \
                    	-Djava.util.logging.config.file=${CRAWLER_HOME}/etc/$2.logging.properties \
                    	-Dlog4j.configuration=file://${SPDM_HOME}/spdm-crawler/etc/log4j.properties \
                        -Dorg.apache.oodt.cas.crawl.bean.repo=file://${CRAWLER_HOME}/policy/crawler-config.xml \
                        -Dgov.nasa.smap.spdm.crawl.ancillary.map=${CRAWLER_HOME}/policy/preprocessor-ancillary-type-map.xml \
                        gov.nasa.smap.spdm.crawl.SpdmCrawlerLauncher \
                        -cid SpdmAutoDetectProductCrawler -fm ${FILEMGR_URL} -ais ${ACTIONS} \
                        -sd ${CRAWLER_SUCCESS_DIR} \
                        -fd ${CRAWLER_FAILURE_DIR} \
                        -ct gov.nasa.smap.spdm.filemgr.datatransfer.SpdmLocalDataTransferFactory \
                        -mxr ${CRAWLER_HOME}/policy/l2_ext-mime-extractor-map.xml \
                        --daemonPort ${L2PP_CRAWLER_DAEMON_PORT} --daemonWait ${L2PP_CRAWLER_WAIT} \
                        -pp ${L2PP_CRAWLER_PATH} ${L2PP_CRAWLER_NR} &
                    echo $! >${PID_HOME}/l2pp-crawler.pid
                    echo "L2PP file crawler started."
                fi
                ;;
            asf-pan)
                sh ${SPDM_HOME}/spdm-main/bin/spdm_status.sh crawler $2
                if [ -f ${PID_HOME}/asf-pan-crawler.pid ] ; then
                    echo "ASF PAN file crawler is already running."
                else
                    PRECONDITIONS="CheckPanFileExistence"
                    ACTIONS="ProcessAsfPdrResponse"
                    ${JAVA_CMD} -Djava.ext.dirs=${CRAWLER_HOME}/lib \
                    	-Djava.util.logging.config.file=${CRAWLER_HOME}/etc/$2.logging.properties \
                    	-Dlog4j.configuration=file://${SPDM_HOME}/spdm-crawler/etc/log4j.properties \
                        -Dorg.apache.oodt.cas.crawl.bean.repo=file://${CRAWLER_HOME}/policy/crawler-config.xml \
                        gov.nasa.smap.spdm.crawl.SpdmCrawlerLauncher \
                        -cid SpdmNoMetCrawler -fm ${FILEMGR_URL} -pids ${PRECONDITIONS} -ais ${ACTIONS} \
                        -ct gov.nasa.smap.spdm.filemgr.datatransfer.SpdmLocalDataTransferFactory \
                        -mx gov.nasa.smap.spdm.crawl.metadata.extractor.PanMetExtractor \
                        --daemonPort ${ASF_PAN_CRAWLER_DAEMON_PORT} --daemonWait ${ASF_PAN_CRAWLER_WAIT} \
                        -pp ${ASF_INTERNAL_HOME} ${ASF_PAN_CRAWLER_NR} \
                        -id ${PAN_CRAWLER_INCLUDE_DIRS} \
                        --skipIngest &
                    echo $! >${PID_HOME}/asf-pan-crawler.pid
                    echo "ASF PAN file crawler started."
                fi
                ;;
            l4-pan)
                sh ${SPDM_HOME}/spdm-main/bin/spdm_status.sh crawler $2
                if [ -f ${PID_HOME}/l4-pan-crawler.pid ] ; then
                    echo "L4 PAN file crawler is already running."
                else
                    PRECONDITIONS="CheckPanFileExistence"
                    ACTIONS="ProcessL4PdrResponse"
                    ${JAVA_CMD} -Djava.ext.dirs=${CRAWLER_HOME}/lib \
                    	-Djava.util.logging.config.file=${CRAWLER_HOME}/etc/$2.logging.properties \
                    	-Dlog4j.configuration=file://${SPDM_HOME}/spdm-crawler/etc/log4j.properties \
                        -Dorg.apache.oodt.cas.crawl.bean.repo=file://${CRAWLER_HOME}/policy/crawler-config.xml \
                        gov.nasa.smap.spdm.crawl.SpdmCrawlerLauncher \
                        -cid SpdmNoMetCrawler -fm ${FILEMGR_URL} -pids ${PRECONDITIONS} -ais ${ACTIONS} \
                        -ct gov.nasa.smap.spdm.filemgr.datatransfer.SpdmLocalDataTransferFactory \
                        -mx gov.nasa.smap.spdm.crawl.metadata.extractor.PanMetExtractor \
                        --daemonPort ${L4_PAN_CRAWLER_DAEMON_PORT} --daemonWait ${L4_PAN_CRAWLER_WAIT} \
                        -pp ${L4_INTERNAL_HOME} ${L4_PAN_CRAWLER_NR} \
                        -id ${PAN_CRAWLER_INCLUDE_DIRS} \
                        --skipIngest &
                    echo $! >${PID_HOME}/l4-pan-crawler.pid
                    echo "L4 PAN file crawler started."
                fi
                ;;
            nsidc-pan)
                sh ${SPDM_HOME}/spdm-main/bin/spdm_status.sh crawler $2
                if [ -f ${PID_HOME}/nsidc-pan-crawler.pid ] ; then
                    echo "NSIDC PAN file crawler is already running."
                else
                    PRECONDITIONS="CheckPanFileExistence"
                    ACTIONS="ProcessNsidcPdrResponse"
                    ${JAVA_CMD} -Djava.ext.dirs=${CRAWLER_HOME}/lib \
                    	-Djava.util.logging.config.file=${CRAWLER_HOME}/etc/$2.logging.properties \
                    	-Dlog4j.configuration=file://${SPDM_HOME}/spdm-crawler/etc/log4j.properties \
                        -Dorg.apache.oodt.cas.crawl.bean.repo=file://${CRAWLER_HOME}/policy/crawler-config.xml \
                        gov.nasa.smap.spdm.crawl.SpdmCrawlerLauncher \
                        -cid SpdmNoMetCrawler -fm ${FILEMGR_URL} -pids ${PRECONDITIONS} -ais ${ACTIONS} \
                        -ct gov.nasa.smap.spdm.filemgr.datatransfer.SpdmLocalDataTransferFactory \
                        -mx gov.nasa.smap.spdm.crawl.metadata.extractor.PanMetExtractor \
                        --daemonPort ${NSIDC_PAN_CRAWLER_DAEMON_PORT} --daemonWait ${NSIDC_PAN_CRAWLER_WAIT} \
                        -pp ${NSIDC_INTERNAL_HOME} ${NSIDC_PAN_CRAWLER_NR} \
                        -id ${PAN_CRAWLER_INCLUDE_DIRS} \
                        --skipIngest &
                    echo $! >${PID_HOME}/nsidc-pan-crawler.pid
                    echo "NSIDC PAN file crawler started."
                fi
                ;;
            asf-pdrd)
                sh ${SPDM_HOME}/spdm-main/bin/spdm_status.sh crawler $2
                if [ -f ${PID_HOME}/asf-pdrd-crawler.pid ] ; then
                    echo "ASF PDRD file crawler is already running."
                else
                    PRECONDITIONS="CheckPdrdFileExistence"
                    ACTIONS="ProcessAsfPdrResponse"
                    ${JAVA_CMD} -Djava.ext.dirs=${CRAWLER_HOME}/lib \
                    	-Djava.util.logging.config.file=${CRAWLER_HOME}/etc/$2.logging.properties \
                    	-Dlog4j.configuration=file://${SPDM_HOME}/spdm-crawler/etc/log4j.properties \
                        -Dorg.apache.oodt.cas.crawl.bean.repo=file://${CRAWLER_HOME}/policy/crawler-config.xml \
                        gov.nasa.smap.spdm.crawl.SpdmCrawlerLauncher \
                        -cid SpdmNoMetCrawler -fm ${FILEMGR_URL} -pids ${PRECONDITIONS} -ais ${ACTIONS} \
                        -ct gov.nasa.smap.spdm.filemgr.datatransfer.SpdmLocalDataTransferFactory \
                        -mx gov.nasa.smap.spdm.crawl.metadata.extractor.PanMetExtractor \
                        --daemonPort ${ASF_PDRD_CRAWLER_DAEMON_PORT} --daemonWait ${ASF_PDRD_CRAWLER_WAIT} \
                        -pp ${ASF_INTERNAL_HOME} ${ASF_PDRD_CRAWLER_NR} \
                        -id ${PDRD_CRAWLER_INCLUDE_DIRS} \
                        --skipIngest &
                    echo $! >${PID_HOME}/asf-pdrd-crawler.pid
                    echo "ASF PDRD file crawler started."
                fi
                ;;
            l4-pdrd)
                sh ${SPDM_HOME}/spdm-main/bin/spdm_status.sh crawler $2
                if [ -f ${PID_HOME}/l4-pdrd-crawler.pid ] ; then
                    echo "L4 PDRD file crawler is already running."
                else
                    PRECONDITIONS="CheckPdrdFileExistence"
                    ACTIONS="ProcessL4PdrResponse"
                    ${JAVA_CMD} -Djava.ext.dirs=${CRAWLER_HOME}/lib \
                    	-Djava.util.logging.config.file=${CRAWLER_HOME}/etc/$2.logging.properties \
                    	-Dlog4j.configuration=file://${SPDM_HOME}/spdm-crawler/etc/log4j.properties \
                        -Dorg.apache.oodt.cas.crawl.bean.repo=file://${CRAWLER_HOME}/policy/crawler-config.xml \
                        gov.nasa.smap.spdm.crawl.SpdmCrawlerLauncher \
                        -cid SpdmNoMetCrawler -fm ${FILEMGR_URL} -pids ${PRECONDITIONS} -ais ${ACTIONS} \
                        -ct gov.nasa.smap.spdm.filemgr.datatransfer.SpdmLocalDataTransferFactory \
                        -mx gov.nasa.smap.spdm.crawl.metadata.extractor.PanMetExtractor \
                        --daemonPort ${L4_PDRD_CRAWLER_DAEMON_PORT} --daemonWait ${L4_PDRD_CRAWLER_WAIT} \
                        -pp ${L4_INTERNAL_HOME} ${L4_PDRD_CRAWLER_NR} \
                        -id ${PDRD_CRAWLER_INCLUDE_DIRS} \
                        --skipIngest &
                    echo $! >${PID_HOME}/l4-pdrd-crawler.pid
                    echo "L4 PDRD file crawler started."
                fi
                ;;
            nsidc-pdrd)
                sh ${SPDM_HOME}/spdm-main/bin/spdm_status.sh crawler $2
                if [ -f ${PID_HOME}/nsidc-pdrd-crawler.pid ] ; then
                    echo "NSIDC PDRD file crawler is already running."
                else
                    PRECONDITIONS="CheckPdrdFileExistence"
                    ACTIONS="ProcessNsidcPdrResponse"
                    ${JAVA_CMD} -Djava.ext.dirs=${CRAWLER_HOME}/lib \
                    	-Djava.util.logging.config.file=${CRAWLER_HOME}/etc/$2.logging.properties \
                    	-Dlog4j.configuration=file://${SPDM_HOME}/spdm-crawler/etc/log4j.properties \
                        -Dorg.apache.oodt.cas.crawl.bean.repo=file://${CRAWLER_HOME}/policy/crawler-config.xml \
                        gov.nasa.smap.spdm.crawl.SpdmCrawlerLauncher \
                        -cid SpdmNoMetCrawler -fm ${FILEMGR_URL} -pids ${PRECONDITIONS} -ais ${ACTIONS} \
                        -ct gov.nasa.smap.spdm.filemgr.datatransfer.SpdmLocalDataTransferFactory \
                        -mx gov.nasa.smap.spdm.crawl.metadata.extractor.PanMetExtractor \
                        --daemonPort ${NSIDC_PDRD_CRAWLER_DAEMON_PORT} --daemonWait ${NSIDC_PDRD_CRAWLER_WAIT} \
                        -pp ${NSIDC_INTERNAL_HOME} ${NSIDC_PDRD_CRAWLER_NR} \
                        -id ${PDRD_CRAWLER_INCLUDE_DIRS} \
                        --skipIngest &
                    echo $! >${PID_HOME}/nsidc-pdrd-crawler.pid
                    echo "NSIDC PDRD file crawler started."
                fi
                ;;
            general)
                sh ${SPDM_HOME}/spdm-main/bin/spdm_status.sh crawler $2
                if [ -f ${PID_HOME}/general-crawler.pid ] ; then
                    echo "General file crawler is already running."
                else
                    ACTIONS="Unique FileSizeGreaterThanZero DeleteDataFile DeleteMetadataFile MoveDataFileToFailureDir MoveMetadataToFailureDir"
                    ${JAVA_CMD} -Djava.util.logging.config.file=${CRAWLER_HOME}/etc/$2.logging.properties \
                        -Dlog4j.configuration=file://${SPDM_HOME}/spdm-crawler/etc/log4j.properties \
                        -Djava.ext.dirs=${CRAWLER_HOME}/lib \
                        -Dorg.apache.oodt.cas.crawl.bean.repo=file://${CRAWLER_HOME}/policy/crawler-config.xml \
                        gov.nasa.smap.spdm.crawl.SpdmCrawlerLauncher \
                        -cid SpdmStdProductCrawler -fm ${FILEMGR_URL} -ais ${ACTIONS} -mfx met \
                        -ct gov.nasa.smap.spdm.filemgr.datatransfer.SpdmLocalDataTransferFactory \
                        -sd ${CRAWLER_SUCCESS_DIR} \
                        -fd ${CRAWLER_FAILURE_DIR} \
                        --daemonPort ${GENERAL_CRAWLER_DAEMON_PORT} --daemonWait ${GENERAL_CRAWLER_WAIT} \
                        -pp ${GENERAL_CRAWLER_PATH} ${GENERAL_CRAWLER_NR} &
                    echo $! >${PID_HOME}/general-crawler.pid
                    echo "General file crawler started."
                fi
                ;;
            lut_history)
                sh ${SPDM_HOME}/spdm-main/bin/spdm_status.sh crawler $2
                if [ -f ${PID_HOME}/lut_history-crawler.pid ] ; then
                    echo "LUT History crawler is already running."
                else
                    PRECONDITIONS="CheckLUTHistoryFileExistence CheckSignalFileExistence"
                    ACTIONS="Unique FileSizeGreaterThanZero KickoffLUTHistoryWF DeleteDataFile DeleteSignalFile MoveDataFileToFailureDir MoveSignalFileToFailureDir"
                    ${JAVA_CMD} -Djava.util.logging.config.file=${CRAWLER_HOME}/etc/$2.logging.properties \
                        -Dlog4j.configuration=file://${SPDM_HOME}/spdm-crawler/etc/log4j.properties \
                        -Djava.ext.dirs=${CRAWLER_HOME}/lib \
                        -Dorg.apache.oodt.cas.crawl.bean.repo=file://${CRAWLER_HOME}/policy/crawler-config.xml \
                        gov.nasa.smap.spdm.crawl.SpdmCrawlerLauncher \
                        -cid SpdmNoMetCrawler -fm ${FILEMGR_URL} -pids ${PRECONDITIONS} -ais ${ACTIONS} \
                        -sd ${CRAWLER_SUCCESS_DIR} \
                        -fd ${CRAWLER_FAILURE_DIR} \
                        -ct gov.nasa.smap.spdm.filemgr.datatransfer.SpdmLocalDataTransferFactory \
                        -mx gov.nasa.smap.spdm.crawl.metadata.extractor.LutHistoryMetExtractor \
                        --daemonPort ${LUT_HISTORY_CRAWLER_DAEMON_PORT} --daemonWait ${LUT_HISTORY_CRAWLER_WAIT} \
                        -pp ${LUT_HISTORY_CRAWLER_PATH} ${LUT_HISTORY_CRAWLER_NR} &
                    echo $! >${PID_HOME}/lut_history-crawler.pid
                    echo "LUT History crawler started."
                fi
                ;;
			*)
				echo "To startup individual crawler"
				echo "	Usage: $0 crawler {radar-L0A | radiom-L0A | stuf | gds | l1_ext | antaz | l2pp | asf-pdrd | asf-pan | nsidc-pdrd | nsidc-pan | l4-pdrd | l4-pan | general | lut_history}"
				;;
        esac
		;;
    all-crawler)
        echo "Starting crawlers..."
        sh $0 crawler radar-L0A
        sh $0 crawler radiom-L0A
        sh $0 crawler stuf
        sh $0 crawler gds
        sh $0 crawler l1_ext
        sh $0 crawler antaz
        sh $0 crawler l2pp
        sh $0 crawler asf-pan
        sh $0 crawler l4-pan
        sh $0 crawler nsidc-pan
        sh $0 crawler asf-pdrd
        sh $0 crawler l4-pdrd
        sh $0 crawler nsidc-pdrd
        sh $0 crawler general
        sh $0 crawler lut_history
        echo "Crawler daemons started."
        sleep 20
        ;;
	timer)
		sh ${SPDM_HOME}/spdm-main/bin/spdm_status.sh timer
		if [ -f ${PID_HOME}/spdm-timer.pid ] ; then
    		echo "Timer Launcher is already running."
		else
			echo "Starting timer launcher."
			export SPDM_MAIN=${SPDM_HOME}/spdm-main
			${JAVA_CMD} -Djava.ext.dirs=${SPDM_MAIN}/lib \
				-Djava.util.logging.config.file=${SPDM_MAIN}/etc/timer.logging.properties \
				-Dlog4j.configuration=file://${SPDM_HOME}/spdm-main/etc/timer.log4j.properties \
				gov.nasa.smap.spdm.main.timer.WorkflowTimerLauncher -daemon &
    		echo $! >${PID_HOME}/spdm-timer.pid
			echo "Timer launcher started."
			sleep 5
		fi
        ;;
	all-service)
		sh $0 filemgr
		sh $0 resource
		sh $0 all-batchstub
		sh $0 workflow
		sh $0 all-crawler
		sh $0 timer all
		echo "Startup of filemgr, resource, all-batchstub, workflow, all-crawler, & timer services finished."
		;;
	all)
		sh $0 filemgr
		sh $0 resource
		sh $0 all-batchstub
		sh $0 workflow
		sh $0 all-crawler
		echo "Startup of filemgr, resource, all-batchstub, workflow, & all-crawler services finished."
		;;
	*)
		echo "To startup services except for timer"
		echo "	Usage: $0 all"
		echo "To startup services including timer"
		echo "	Usage: $0 all-service"
		echo "To start individual component"
		echo "	Usage: $0 {filemgr | resource | all-batchstub | workflow | all-crawler | timer}"
		echo "To startup individual crawler"
		echo "	Usage: $0 crawler {radar-L0A | radiom-L0A | stuf | gds | l1_ext | antaz | l2pp | asf-pdrd | asf-pan | nsidc-pdrd | nsidc-pan | l4-pdrd | l4-pan | general | lut_history}"
		echo "To startup individual batch stub"
		echo "	Usage: $0 batchstub {nodename}"
		;;
esac
