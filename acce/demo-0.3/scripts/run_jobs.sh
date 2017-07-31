#!/bin/bash

NJOBS=2000
NHOSTS=20
SLEEP_SECS=1
WORKFLOW_URL=http://internal-EcostressLoadBalancer-1621470833.us-west-2.elb.amazonaws.com:9001
echo "Running $NJOBS jobs"

# identify first container with workflow manager client installed
wrkr_ids=`docker ps | grep Oodt03Demo | awk '{print $1}' | awk '{print $1}'`
wrkr_id=`echo $wrkr_ids | awk '{print $1;}'`
echo "Submitting to container: $wrkr_id"

# run jobs
for ((i=1;i<=NJOBS;i++)); do
   # submit workflow $i
   echo "Submitting workflow # $i"
   docker exec -it $wrkr_id sh -c "cd /usr/local/oodt/cas-workflow/bin; ./wmgr-client --url $WORKFLOW_URL --operation --sendEvent --eventName test-workflow --metaData --key Dataset abc --key Project 123 --key Run $i"
   x=$(($i % $NHOSTS))
   # wait $SLEEP_SECS seconds before submitting the next 100 workflows
   if [ $x == 0 ]; then
      echo "Sleeping..."
      sleep $SLEEP_SECS
   fi
done
