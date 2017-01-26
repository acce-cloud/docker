#!/bin/sh
# Copyright 2009-2015, by the California Institute of Technology.
# ALL RIGHTS RESERVED. United States Government Sponsorship acknowledged.

export SPDM_VERSION=1.4.2

# Host machine for spdm services
export SPDM_HOST=localhost
export SPDM_WS_URL=http://localhost:8080/spdm-ws
export WEBSERVER_URLS=http://localhost:9080,http://localhost:9080

# Default CRID used for processing
export COMPOSITE_RELEASE_ID=D00001

#--- SDS & LOM directory ---
export SDS_HOME=${SPDM_HOME}/spdm-main/bin/test/testdata/regression/sds
export LOM_HOME=/project/spdm/store

#--- SPDM Working Areas ---
export SPDM_WORKSPACE=/project/spdm/workspace/1.4.2/processing
export ANALYSIS_HOME=/project/spdm/workspace/1.4.2/analysis
export FAILED_TASK_HOME=/project/spdm/workspace/1.4.2/failed_tasks
export REPORT_HOME=/project/spdm/workspace/1.4.2/reports/${COMPOSITE_RELEASE_ID}

#-- PID Storage Dir ---
export PID_HOME=/project/spdm/workspace/pid
export SQL_REPO=/project/spdm/workspace/sql-repo

#--- Workflow Lucene Repository ---
export WORKFLOW_LUCENE_HOME=/project/spdm/workspace/1.4.2/lucene

#--- Crawler Configuration ---
# Crawler post-ingestion areas
export CRAWLER_SUCCESS_DIR=/project/spdm/staging/successDir
export CRAWLER_FAILURE_DIR=/project/spdm/staging/failureDir
#
# Crawler master wait time in seconds
#
export CRAWLER_MASTER_WAIT=120
export PAN_PDRD_CRAWLER_WAIT=600
export GDS_CRAWLER_WAIT=${CRAWLER_MASTER_WAIT}
export L1_EXT_CRAWLER_WAIT=${CRAWLER_MASTER_WAIT}
export ANTAZ_CRAWLER_WAIT=${CRAWLER_MASTER_WAIT}
export L2PP_CRAWLER_WAIT=${CRAWLER_MASTER_WAIT}
export STUF_CRAWLER_WAIT=${CRAWLER_MASTER_WAIT}
export RADAR_L0A_CRAWLER_WAIT=${CRAWLER_MASTER_WAIT}
export RADIOMETER_L0A_CRAWLER_WAIT=${CRAWLER_MASTER_WAIT}
export ASF_PAN_CRAWLER_WAIT=${PAN_PDRD_CRAWLER_WAIT}
export NSIDC_PAN_CRAWLER_WAIT=${PAN_PDRD_CRAWLER_WAIT}
export L4_PAN_CRAWLER_WAIT=${PAN_PDRD_CRAWLER_WAIT}
export ASF_PDRD_CRAWLER_WAIT=${PAN_PDRD_CRAWLER_WAIT}
export NSIDC_PDRD_CRAWLER_WAIT=${PAN_PDRD_CRAWLER_WAIT}
export L4_PDRD_CRAWLER_WAIT=${PAN_PDRD_CRAWLER_WAIT}
export GENERAL_CRAWLER_WAIT=${CRAWLER_MASTER_WAIT}
export LUT_HISTORY_CRAWLER_WAIT=${CRAWLER_MASTER_WAIT}

# Value in seconds to tell PAN/PDRD crawler which files to skip until next crawl
export PAN_PDRD_CRAWLER_LAST_MODIFIED=180

# Retry duration for ANTAZ 
export ANTAZ_RETRY_DURATION=${CRAWLER_MASTER_WAIT}

# Crawler staging areas for incoming data
export GDS_CRAWLER_PATH=/project/spdm/staging/gds
export L1_EXT_CRAWLER_PATH=/project/spdm/staging/L1_EXT
export ANTAZ_CRAWLER_PATH=/project/spdm/staging/gds/ANTAZ
export L2PP_CRAWLER_PATH=/project/spdm/staging/L2_EXT
export STUF_CRAWLER_PATH=/project/spdm/staging/gds/stuf
export RADAR_L0A_CRAWLER_PATH=/project/spdm/staging/edos/incoming
export RADIOMETER_L0A_CRAWLER_PATH=/project/spdm/staging/edos/incoming
export GENERAL_CRAWLER_PATH=/project/spdm/staging/general
export LUT_HISTORY_CRAWLER_PATH=/project/spdm/staging/gds/LUTHistory

#--- Port numbers ---
export FILEMGR_PORT=9000
export WORKFLOWMGR_PORT=9001
export RESOURCEMGR_PORT=9002
export BATCH_STUB_PORT=9003
# inbound area crawlers
export GDS_CRAWLER_DAEMON_PORT=9010
export L1_EXT_CRAWLER_DAEMON_PORT=9011
export ANTAZ_CRAWLER_DAEMON_PORT=9012
export L2PP_CRAWLER_DAEMON_PORT=9013
export STUF_CRAWLER_DAEMON_PORT=9014
export RADAR_L0A_CRAWLER_DAEMON_PORT=9015
export RADIOMETER_L0A_CRAWLER_DAEMON_PORT=9016
export GENERAL_CRAWLER_DAEMON_PORT=9017
export LUT_HISTORY_CRAWLER_DAEMON_PORT=9018
# outbound area crawlers
export ASF_PAN_CRAWLER_DAEMON_PORT=9020
export NSIDC_PAN_CRAWLER_DAEMON_PORT=9021
export L4_PAN_CRAWLER_DAEMON_PORT=9022
export ASF_PDRD_CRAWLER_DAEMON_PORT=9023
export NSIDC_PDRD_CRAWLER_DAEMON_PORT=9024
export L4_PDRD_CRAWLER_DAEMON_PORT=9025

#--- Database information ---
#--- Do not include the domain name in the DB_HOST
export DB_HOST=jplis-dta-ecostrsd.jpl.nasa.gov
export DB_PORT=1521
export DB_INSTANT=ECOSTRSD

#--- Database username and password ---
export FILEMGR_DB_USER=
export FILEMGR_DB_PASS=

#--- LDAP url and LDAP users ---
export LDAP_URL=ldap://ldap.jpl.nasa.gov:389
export LDAP_SEARCHBASE=ou=personnel,dc=dir,dc=jpl,dc=nasa,dc=gov
export LDAP_USERS=${USER}

#-- EMAIL list for notification ---
export EMAIL_LIST=${USER}@jpl.nasa.gov

#-- DAAC/L4 Subsystem Data Staging ---
export ASF_INTERNAL_HOME=/project/spdm/project/staging/asf/export/staging/asf
export NSIDC_INTERNAL_HOME=/project/spdm/project/staging/jail/home/nsidc
export L4_INTERNAL_HOME=/project/spdm/project/staging/jail/home/gsfc
export ASF_INTERNAL_PATH=${ASF_INTERNAL_HOME}/ops
export NSIDC_INTERNAL_PATH=${NSIDC_INTERNAL_HOME}/ops
export L4_INTERNAL_PATH=${L4_INTERNAL_HOME}/ops
export ASF_INTERNAL_PATH_REPROC=${ASF_INTERNAL_HOME}/rproc
export NSIDC_INTERNAL_PATH_REPROC=${NSIDC_INTERNAL_HOME}/rproc
export L4_INTERNAL_PATH_REPROC=${L4_INTERNAL_HOME}/rproc

#-- Resource Manager node configuration ---
#-- This must be set to one of dev, int, ops, or subsys
export RESOURCE_VENUE=dev

#======================================================
# Don't change lines below
# Derived Parameters from the configuration above
#======================================================

#--- Server URL ---
export FILEMGR_URL=http://${SPDM_HOST}:${FILEMGR_PORT}
export WORKFLOWMGR_URL=http://${SPDM_HOST}:${WORKFLOWMGR_PORT}
export RESOURCEMGR_URL=http://${SPDM_HOST}:${RESOURCEMGR_PORT}

#--- JDBC Parameters ---
export FILEMGR_DB_DRIVER=oracle.jdbc.driver.OracleDriver
export FILEMGR_DB_URL=jdbc:oracle:thin:@${DB_HOST}:${DB_PORT}:${DB_INSTANT}

#--- SPDM Component Locations ---
export FILEMGR_HOME=${SPDM_HOME}/spdm-filemgr
export WORKFLOWMGR_HOME=${SPDM_HOME}/spdm-workflow
export RESOURCEMGR_HOME=${SPDM_HOME}/spdm-resource
export CRAWLER_HOME=${SPDM_HOME}/spdm-crawler
export SPDM_SCRIPTS_HOME=${SPDM_HOME}/spdm-main
export PGECONFIG_HOME=${SPDM_HOME}/spdm-pge

#--- File Manager Required Parameters ---
export SPDM_LOG_HOME=/project/spdm/workspace/1.4.2/logs
export HOST=${HOSTNAME}

#-- DAAC/L4 Subsystem crawler sub-directories to include during crawling ---
export PAN_CRAWLER_INCLUDE_DIRS="ops rproc oasis PAN"
export PDRD_CRAWLER_INCLUDE_DIRS="ops rproc oasis PDRD"

# Crawler sub-directories to exclude during crawling
export GDS_CRAWLER_EXCLUDE_DIRS="stuf ANTAZ .ssh usr LUTHistory"

# Crawler recursive option
export ANTAZ_CRAWLER_NR=-nr
export L2PP_CRAWLER_NR=-nr
export STUF_CRAWLER_NR=-nr
export RADAR_L0A_CRAWLER_NR=-nr
export RADIOMETER_L0A_CRAWLER_NR=-nr
export ASF_PAN_CRAWLER_NR=
export NSIDC_PAN_CRAWLER_NR=
export L4_PAN_CRAWLER_NR=
export ASF_PDRD_CRAWLER_NR=
export NSIDC_PDRD_CRAWLER_NR=
export L4_PDRD_CRAWLER_NR=
export GENERAL_CRAWLER_NR=-nr
export LUT_HISTORY_CRAWLER_NR=-nr

# Set the timestamp to UTC
export TZ=UTC

# Path to the DEM files needed by the L2_S0_S1 Pre-Processor
DEM_L2_S0_S1_PATH=/cm/ancillary/DEM
