#!/bin/bash

# OODT Workflow Manager
cd $OODT_HOME/cas-workflow/bin
./wmgr start

# wait for rabbitmq server to finish initialization of OODT user accounts
sleep 10

# start the rabbitmq consumers
# one consumer per workflow specified as script argument
for arg in "$@"; do
  echo "RabbitMQ consumer listening to queue ${arg}..."
  python /usr/local/oodt/rabbitmq/rabbitmq_client.py pull $arg 2 &
done

# keep container running
tail -f $OODT_HOME/cas-workflow/logs/cas_workflow.log
