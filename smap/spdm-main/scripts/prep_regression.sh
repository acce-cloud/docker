#!/bin/sh
alias docker="sudo docker"
# Script that submits the regression test
docker_spdm_id=`docker ps | grep oodthub/spdm-services | awk '{print $1}'`
#
# Perform regression steps according to 
# https://github.jpl.nasa.gov/SPDM/spdm/blob/master/spdm-main/src/test/bin/regression/README.txt
#
docker exec -it ${docker_spdm_id} sh -c 'cd $SPDM_HOME/spdm-main/bin/test/regression; sh regression_testSetup.sh'
echo "Waiting 2 minutes to finish cleanup & setup..."
sleep 120
docker exec -it ${docker_spdm_id} sh -c 'cd $SPDM_HOME/spdm-main/bin/test/regression; sh drop_files_into_crawler_dirs.sh'
echo "Waiting 2 minutes to finish inputs setup..."
sleep 120
docker exec -it ${docker_spdm_id} sh -c 'cd $SPDM_HOME/spdm-main/bin; sh onDemand.sh stuf_1309010000_1310010000_1308311408_pln_OD0001_v01.xml -auto'
echo "Waiting a minute to finish orbit info population..."
sleep 60
