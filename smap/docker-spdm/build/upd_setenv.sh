#!/bin/sh
#
if [ -r credentials.sh ] ; then 
   . credentials.sh
fi

[ ! -z $1 ] && SPDM_DB_USER=$1
[ ! -z $2 ] && SPDM_DB_PASS=$2

echo ${PWD}
ls -l ${PWD}

ORIGFILE=${PWD}/setenv.sh

if [ -r ${ORIGFILE} ] ; then 
   . ${ORIGFILE}
fi
if [ -z ${SPDM_DB_USER} ] || [ -z {SPDM_DB_PASS} ] ; then
   echo "Env SPDM_DB_USER or SPDM_DB_PASS undefined for ${DB_HOST}/${DB_INSTANT}!"
   exit
fi
echo "Updating ${ORIGFILE} with database credentials"
echo ${SPDM_DB_USER}:${SPDM_DB_PASS}@${DB_HOST}/${DB_INSTANT}
NEWFILE=./setenv.sh.new
# refresh back to original file
[ -e ${ORIGFILE}.orig ] && mv ${ORIGFILE}.orig ${ORIGFILE}
# update with your credentials
sed 's/FILEMGR_DB_USER=/FILEMGR_DB_USER='${SPDM_DB_USER}'/' ${ORIGFILE} |  \
sed 's/FILEMGR_DB_PASS=/FILEMGR_DB_PASS='${SPDM_DB_PASS}'/' > ${NEWFILE}
mv ${ORIGFILE} ${ORIGFILE}.orig
mv ${NEWFILE} ${ORIGFILE}
grep FILEMGR_DB ${ORIGFILE}
