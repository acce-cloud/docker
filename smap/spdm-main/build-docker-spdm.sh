#!/bin/sh
if [ -r ./credentials.sh ] ; then 
   . ./credentials.sh
else
   echo "Please copy build/credentials.sh template to this directory & add your credentials"
fi
echo "${JPL_GIT_USER}:${JPL_GIT_TOKEN}:${SPDM_DB_HOST}:${SPDM_DB_PORT}:${SPDM_DB_INSTANT}:${SPDM_DB_USER}:${SPDM_DB_PASS}"
sudo docker build -t oodthub/spdm-services:0.3 \
              --build-arg jpl_git_user=${JPL_GIT_USER} \
              --build-arg jpl_git_token=${JPL_GIT_TOKEN} \
              --build-arg spdm_db_host=${SPDM_DB_HOST} \
              --build-arg spdm_db_port=${SPDM_DB_PORT} \
              --build-arg spdm_db_instant=${SPDM_DB_INSTANT} \
              --build-arg spdm_db_user=${SPDM_DB_USER} \
              --build-arg spdm_db_pass=${SPDM_DB_PASS} .
