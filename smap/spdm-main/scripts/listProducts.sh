#!/bin/sh
alias docker="sudo docker"
# Script that submits the regression test
docker_spdm_id=`docker ps | grep oodthub/spdm-services | awk '{print $1}'`
#
# Verify products generated
#
docker exec -it ${docker_spdm_id} sh -c 'ls -lt /project/spdm/store/PRODUCTS/*/*/*/*/*'
