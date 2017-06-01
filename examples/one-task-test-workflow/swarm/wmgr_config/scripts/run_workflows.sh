#!/bin/sh
# shell script to submit N workflows to the URL: http://wmgr:9001 
# Example: ./run_workflows.sh N

cd $OODT_HOME/cas-workflow/bin
num_workflows=$1
echo "Total number of workflows: $num_workflows"
for i in `seq 1 $num_workflows`;
do
  echo "Submitting workflow #: $i"
  ./wmgr-client --url http://wmgr:9001 --operation --sendEvent --eventName test-workflow --metaData --key Dataset abc --key Project 123 --key size 1 --key heap 1 --key time 5 --key message_counter $i
done    
