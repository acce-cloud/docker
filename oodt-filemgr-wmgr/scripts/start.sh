#!/bin/bash

# start OODT File Manager
cd $OODT_HOME/cas-filemgr/bin
./filemgr start

# start OODT Workflow Manager
cd $OODT_HOME/cas-workflow/bin
./wmgr start

# keep script running
tail -f $OODT_HOME/cas-workflow/logs/cas_workflow.log
