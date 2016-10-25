#!/bin/sh
# node: acce-build1.dyndns.org
# Script to submit the OODT "test-workflow" N times

wmgr_client_id=`docker ps | grep wmgr-client | awk '{print $1}'`
num_workflows=2

# start date
start_date=`date +%s`
echo "Start date: $start_date (seconds from Epoch)"

for (( i=1; i<=$num_workflows; i++ )) ; do 
  docker exec -it ${wmgr_client_id} sh -c "cd /usr/local/oodt/cas-workflow/bin; ./wmgr-client --url http://wmgr:9001 --operation --sendEvent --eventName test-workflow --metaData --key Dataset abc --key Project 123 --key Run $i"
  sleep 5
done

#curl "http://${MANAGER_IP}:8983/solr/oodt-fm/select?q=*%3A*&wt=json&indent=true&rows=0"

# wait for the last product to show up in the archive
last_dir="/usr/local/adeploy/archive/test-workflow/output_run${num_workflows}_task2_pge10.out"
while ! [ -d $last_dir ];
do
    echo "...waiting for $last_dir"
    sleep 10
done


# stop date
stop_date=`date +%s`
echo "Stop date: $stop_date (seconds from Epoch)"

# elapsed time
elapsed_time="$(($stop_date-$start_date))"
echo "Elapsed time: $elapsed_time (secs)"

