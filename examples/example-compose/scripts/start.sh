#!/bin/bash

# parse command line arguments
args=("$@")
workflow_event=${args[0]}
num_workflow_clients=${args[1]}

# OODT Workflow Manager
cd $OODT_HOME/cas-workflow/bin
./wmgr start

# start the rabbitmq consumers
# will listen to standard output and keep the container running
# wait for rabbitmq server to finish iinitialization of OODT user accounts
sleep 5
python /usr/local/oodt/rabbitmq/workflow_consumer.py $workflow_event $num_workflow_clients

# keep container running
#tail -f $OODT_HOME/cas-workflow/logs/cas_workflow.log
