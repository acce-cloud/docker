#!/bin/sh
#   @author clwong
#
# This script setup SPDM oracle database and tables based on setenv.sh
#
if [ -z $SPDM_HOME ] ; then
   echo "Please setenv SPDM_HOME"
   exit 1
fi
## override environment variables defined in setenv.sh if there is one
if [ -r $SPDM_HOME/spdm-main/bin/setenv.sh ]; then
   . $SPDM_HOME/spdm-main/bin/setenv.sh
fi
cd ${SPDM_HOME}/spdm-filemgr/bin
if [ ! -d $SPDM_HOME/spdm-filemgr/policy/sql-repo ]; then
  mkdir $SPDM_HOME/spdm-filemgr/policy/sql-repo
fi
echo "${FILEMGR_DB_USER}/${FILEMGR_DB_PASS}@${DB_HOST}:${DB_PORT}/${DB_INSTANT}"
sh updateColumnBasedDB -propFile ../etc/filemgr.properties -cmd create-schema -commit


cd $SPDM_HOME/spdm-filemgr/bin/sql
sqlplus ${FILEMGR_DB_USER}/${FILEMGR_DB_PASS}@${DB_HOST}:${DB_PORT}/${DB_INSTANT} << EOF
@createColdSkyTable.sql
@createDailyStatusTable.sql
@createLutHistoryTable.sql
@createOrbitsStatusTable.sql
@createOrbitsTable.sql
@createProcessStatusTable.sql
@createTimersTable.sql
/
EOF
