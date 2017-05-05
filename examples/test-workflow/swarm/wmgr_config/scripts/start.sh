#!/bin/bash

# parse command line arguments
args=("$@")
workflow_event=${args[0]}
num_workflow_clients=${args[1]}

# OODT Workflow Manager
cd $OODT_HOME/cas-workflow/bin
./wmgr start

# wait for rabbitmq server to finish initialization of OODT user accounts
sleep 5
# start the rabbitmq consumers
# will listen to standard output and keep the container running
#python /usr/local/oodt/rabbitmq/workflow_consumer.py $workflow_event $num_workflow_clients
python /usr/local/oodt/rabbitmq/rabbitmq_consumer.py $workflow_event $num_workflow_clients

# keep container running
#tail -f $OODT_HOME/cas-workflow/logs/cas_workflow.log
