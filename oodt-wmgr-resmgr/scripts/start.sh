#!/bin/bash

# OODT Workflow Manager
cd $OODT_HOME/cas-workflow/bin
./wmgr start

# OODT Resource Manager
cd $OODT_HOME/cas-resource/bin
./resmgr start

# OODT Batch Stub
export PATH=$PATH:${JAVA_HOME}/bin
java -Djava.ext.dirs=../lib org.apache.oodt.cas.resource.system.extern.XmlRpcBatchStub --portNum 2001

# keep container running
tail -f $OODT_HOME/cas-workflow/logs/cas_workflow0.log
