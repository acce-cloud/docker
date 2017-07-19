#!/bin/sh
# node: acce-build1.dyndns.org
# Instantiates services on the swarm.
# Note that all services have access to shared directories on the host

docker node update --label-add oodt_type=manager_node acce-build1.dyndns.org
docker node update --label-add oodt_type=worker_node acce-build2.dyndns.org
docker node update --label-add oodt_type=worker_node acce-build3.dyndns.org

# shared directories
mkdir -p /usr/local/adeploy/archive
mkdir -p /usr/local/adeploy/pges

# start file manager on manager node
docker service create --replicas 1 --name oodt-filemgr -p 9000:9000 --network swarm-network \
                      --constraint 'node.labels.oodt_type==manager_node' \
                      --mount type=bind,src=/usr/local/adeploy/src/docker/acce/demo-0.3/workflows/test-workflow/policy,dst=/usr/local/oodt/workflows/policy \
                      --mount type=bind,src=/usr/local/adeploy/archive,dst=/usr/local/oodt/archive \
                      --mount type=bind,src=/usr/local/adeploy/pges/test-workflow/jobs,dst=/usr/local/oodt/pges/test-workflow/jobs \
                      oodthub/oodt-filemgr:0.3

# start workflow + resource managers on worker nodes
docker service create --replicas 2 --name oodt-worker --network swarm-network \
                      --constraint 'node.labels.oodt_type==worker_node' \
                      --mount type=bind,src=/usr/local/adeploy/archive,dst=/usr/local/oodt/archive \
                      --mount type=bind,src=/usr/local/adeploy/src/docker/acce/demo-0.3/workflows/test-workflow/policy,dst=/usr/local/oodt/workflows/policy \
                      --mount type=bind,src=/usr/local/adeploy/src/docker/acce/demo-0.3/workflows/test-workflow/pge-configs,dst=/usr/local/oodt/workflows/test-workflow/pge-configs \
                      --mount type=bind,src=/usr/local/adeploy/src/docker/acce/demo-0.3/pges/test-workflow,dst=/usr/local/oodt/pges/test-workflow \
                      --mount type=bind,src=/usr/local/adeploy/pges/test-workflow/jobs,dst=/usr/local/oodt/pges/test-workflow/jobs \
                      --env 'FILEMGR_URL=http://oodt-filemgr:9000/' \
                      --env 'WORKFLOW_URL=http://localhost:9001' \
                      --env 'RESMGR_URL=http://localhost:9002' \
                      --env 'RESMGR_HOME=/usr/local/oodt/cas-resource' \
                      oodthub/oodt-wmgr-resmgr:0.3
docker service scale oodt-worker=4

docker service ls
