#!/bin/bash

# identify first worker container
wrkr_ids=`docker ps | grep Oodt03Demo | awk '{print $1}' | awk '{print $1}'`
wrkr_id=`echo $wrkr_ids | awk '{print $1;}'`
echo "Submitting to container: $wrkr_id"

# data archive
for ((i=1;i<=9;i++)); do
  echo "Cleaning up /usr/local/oodt/archive/test-workflow/output_Run_${i}*"
  docker exec -it $wrkr_id sh -c "rm -rf /usr/local/oodt/archive/test-workflow/output_Run_${i}*"
done

# jobs
docker exec -it $wrkr_id sh -c "rm -rf /usr/local/oodt/pges/test-workflow/jobs/a*"
docker exec -it $wrkr_id sh -c "rm -rf /usr/local/oodt/pges/test-workflow/jobs/b*"
docker exec -it $wrkr_id sh -c "rm -rf /usr/local/oodt/pges/test-workflow/jobs/c*"
docker exec -it $wrkr_id sh -c "rm -rf /usr/local/oodt/pges/test-workflow/jobs/d*"
docker exec -it $wrkr_id sh -c "rm -rf /usr/local/oodt/pges/test-workflow/jobs/e*"
docker exec -it $wrkr_id sh -c "rm -rf /usr/local/oodt/pges/test-workflow/jobs/f*"
docker exec -it $wrkr_id sh -c "rm -rf /usr/local/oodt/pges/test-workflow/jobs/*"
