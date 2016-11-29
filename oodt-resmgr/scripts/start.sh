#!/bin/bash

# OODT Resource Manager
cd $OODT_HOME/cas-resource/bin
./resmgr start

# OODT Batch Stub
java -Djava.ext.dirs=../lib org.apache.oodt.cas.resource.system.extern.XmlRpcBatchStub --portNum 2001

# keep script running
cd $OODT_HOME
tail -f $OODT_HOME/cas-resource/logs/cas_resource.log
