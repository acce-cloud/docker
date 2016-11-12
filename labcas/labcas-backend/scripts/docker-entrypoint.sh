#!/bin/bash
# script to start all labcas services

cd $LABCAS_HOME
./start.sh

# keep container running
tail -f /dev/null
