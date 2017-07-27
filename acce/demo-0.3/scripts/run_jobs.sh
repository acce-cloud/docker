BS=10000
SLEEP_SECS=60
WORKFLOW_URL=http://internal-EsgfClassicLoadBalancer-153467213.us-west-2.elb.amazonaws.com:9001
echo "Running $NJOBS jobs"

# identify first worker container
wrkr_ids=`docker ps | grep Oodt03DemoWorker | awk '{print $1}' | awk '{print $1}'`
wrkr_id=`echo $wrkr_ids | awk '{print $1;}'`
echo "Submitting to container: $wrkr_id"

# clean up shared directories
docker exec -it $wrkr_id sh -c "rm -rf /usr/local/oodt/pges/test-workflow/jobs/*"
docker exec -it $wrkr_id sh -c "rm -rf /usr/local/oodt/archive/test-workflow/*"

# run jobs
for ((i=1;i<=NJOBS;i++)); do
   # submit workflow $i
   echo "Submitting workflow # $i"
   x=$(($i % 100))
   # wait 60 seconds before submitting the next 100 workflows
   if [ $x == 0 ]; then
      echo "Sleeping..."
      sleep $SLEEP_SECS
   fi
   docker exec -it $wrkr_id sh -c "cd /usr/local/oodt/cas-workflow/bin; ./wmgr-client --url $WORKFLOW_URL --operation --sendEvent --eventName test-workflow --metaData --key Dataset abc --key Project 123 --key Run $i"
done

