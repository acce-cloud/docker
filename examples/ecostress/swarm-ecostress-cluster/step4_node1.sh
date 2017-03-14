#!/bin/sh
# node: eco-p31
# Submits the ECOSTRESS 'ecostress-L3a-workflow' workflow

wmgr_id=`docker ps | grep wmgr_L3a.1 | awk '{print $1}'`

# execute rabbitmq producer inside workflow manager container
docker exec -it ${wmgr_id} sh -c "cd /usr/local/oodt/rabbitmq; python ecostress_driver.py 1"
