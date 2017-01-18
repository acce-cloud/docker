#!/bin/sh
if [ -r ./credentials.sh ] ; then 
   . ./credentials.sh
fi
docker build -t oodt-hub/spdm-services \
              --build-arg jpl_git_user=${JPL_GIT_USER} \
              --build-arg jpl_git_token=${JPL_GIT_TOKEN} \
              --build-arg spdm_db_user=${SPDM_DB_USER} \
              --build-arg spdm_db_pass=${SPDM_DB_PASS} .
