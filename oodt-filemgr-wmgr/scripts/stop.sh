#!/bin/bash

# stop OODT File Manager
cd $OODT_HOME/cas-filemgr/bin
./filemgr stop

# stop CAS Workflow Manager
cd $OODT_HOME/cas-workflow/bin
./wmgr stop

cd $OODT_HOME
