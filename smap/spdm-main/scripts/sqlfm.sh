#!/bin/sh
# This is to test sql and fm ingestion before big preparation job.
# Cut & paste this content and run inside a container with FM server or sqlplus
#
## override environment variables defined in setenv.sh if there is one
pushd ${SPDM_HOME}/spdm-main/bin
if [ -r ./setenv.sh ]; then
   . ./setenv.sh
fi
popd

simulated_types=( \
   [0]=STUF \
)
pushd ${SPDM_HOME}/spdm-main/bin/test/utilities

# Remove simulated outputs
for (( i = 0; i < ${#simulated_types[@]}; i++))
do
    echo "Removing all products of type '${simulated_types[i]}' from catalog"
    sh removeByTypeFromCatalog.sh ${simulated_types[i]}
done

popd

username=${FILEMGR_DB_USER}
password=${FILEMGR_DB_PASS}
if [ ! -z ${DB_DOMAIN} ] ; then
  DB_INSTANT=${DB_INSTANT}${DB_DOMAIN}
fi
echo "$0: $username/$password@${DB_HOST}:${DB_PORT}/${DB_INSTANT}"
sqlplus $username/$password@${DB_HOST}:${DB_PORT}/${DB_INSTANT} << EOF
delete from ORBITS;
truncate table LUT_HISTORY;
truncate table ORBITSSTATUS;
truncate table DAILYSTATUS;
/
EOF
