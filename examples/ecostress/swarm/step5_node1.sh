#!/bin/sh
# node: acce-build1.dyndns.org
# Submits the ECOSTRESS 'ecostress-L3a-workflow' workflow

wmgr_id=`docker ps | grep wmgr_head_node | awk '{print $1}'`

# execute rabbitmq producer inside workflow manager container
docker exec -it ${wmgr_id} sh -c "cd /usr/local/oodt/rabbitmq; python ecostress_driver.py 1"
