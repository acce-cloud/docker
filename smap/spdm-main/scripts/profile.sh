#!/bin/sh
alias dexec="docker exec -it `docker ps | grep oodthub/spdm-services | awk '{print $1}'` sh"
alias vwmlog="view /shared-smap-data/spdm/spdmops/workspace/1.4.2/logs/`docker ps | grep oodthub/spdm-services | awk '{print $1}'`/workflow_`date "+%Y-%m-%d"`.log"
alias wmlog="tail -f /shared-smap-data/spdm/spdmops/workspace/1.4.2/logs/`docker ps | grep oodthub/spdm-services | awk '{print $1}'`/workflow_`date "+%Y-%m-%d"`.log"
alias wf="grep -e SEVERE -e Starting -e Finished /shared-smap-data/spdm/spdmops/workspace/1.4.2/logs/`docker ps | grep oodthub/spdm-services | awk '{print $1}'`/workflow_`date "+%Y-%m-%d"`.log"
alias log='cd /shared-smap-data/spdm/spdmops/workspace/1.4.2/logs'
alias stage='cd /shared-smap-data/spdm/spdmops/staging'
alias bin='cd /shared-smap-data/spdm/docker/smap/spdm-main/scripts'
