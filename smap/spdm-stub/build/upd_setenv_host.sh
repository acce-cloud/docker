#!/bin/sh
#
echo ${PWD}
ls -l ${PWD}

ORIGFILE=${PWD}/setenv.sh

if [ -r ${ORIGFILE} ] ; then 
   . ${ORIGFILE}
fi
echo "Updating ${ORIGFILE} with SPDM_HOST"
NEWFILE=./setenv.sh.new
# update with SPDM_HOST=spdmserver
sed 's/SPDM_HOST=localhost/SPDM_HOST=spdmserver/' ${ORIGFILE} > ${NEWFILE}
mv ${NEWFILE} ${ORIGFILE}
grep SPDM_HOST ${ORIGFILE}
