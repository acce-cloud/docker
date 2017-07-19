#!/bin/sh
# node: acce-build1.dyndns.org
# Cleans up directories from previous workflows.
# Submits a new set of workflows.

# idenity first WM container
wmgr_id=`docker ps | grep oodt-wmgr.1 | awk '{print $1}'`
echo $wmgr_id

# clean up shared directories
#docker exec -it $wmgr_id sh -c "rm -rf /usr/local/oodt/pges/test-workflow/jobs/*"
#docker exec -it $wmgr_id ls -l /usr/local/oodt/pges/test-workflow/jobs

# submit workflows
docker exec -it $wmgr_id sh -c "cd /usr/local/oodt/cas-workflow/bin; ./wmgr-client --url http://oodt-wmgr:9001 --operation --sendEvent --eventName test-workflow --metaData --key Dataset abc --key Project 123  --key Run 1"
