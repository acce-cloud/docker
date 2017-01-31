#!/bin/sh
# node: acce-build1.dyndns.org
# Submits the OODT "test-workflow" (twice), then queries the Solr catalog

# define URLs to access the RabbitMQ server
#export RABBITMQ_HOST=172.31.4.166 # from acce1
export RABBITMQ_HOST=acce-build1.dyndns.org # from laptop
export RABBITMQ_USER_URL=amqp://oodt-user:changeit@${RABBITMQ_HOST}/%2f
export RABBITMQ_ADMIN_URL=http://oodt-admin:changeit@${RABBITMQ_HOST}:15672

# execute local script to send messages to RabbitMQ server
python ../../wmgr_config/rabbitmq_clients/rabbitmq_producer.py test-workflow 1 Dataset=abc Project=123 heap=1 size=10 time=10

#sleep 10
#curl "http://${RABBITMQ_HOST}:8983/solr/oodt-fm/select?q=*%3A*&wt=json&indent=true&rows=0"
# to delete all records:
# curl "http://${RABBITMQ_HOST}:8983/solr/oodt-fm/update?stream.body=<delete><query>*:*</query></delete>&commit=true"
