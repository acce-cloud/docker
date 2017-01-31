#!/bin/sh
# node: acce-build1.dyndns.org
# Submits the OODT "test-workflow" (twice), then queries the Solr catalog

rabbitmq_id=`docker ps | grep rabbitmq | awk '{print $1}'`

docker exec -it ${rabbitmq_id} sh -c "cd /usr/local/oodt/rabbitmq; python rabbitmq_producer.py test-workflow 10 Dataset=abc Project=123 heap=10 size=10 time=10"

sleep 10
curl "http://${MANAGER_IP}:8983/solr/oodt-fm/select?q=*%3A*&wt=json&indent=true&rows=0"
# to delete all records:
# curl "http://${MANAGER_IP}:8983/solr/oodt-fm/update?stream.body=<delete><query>*:*</query></delete>&commit=true"
