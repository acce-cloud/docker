#!/bin/sh
# script to build (and optionally push) all OODT Docker images
# Usage:
# ./docker_build_all.sh [--push] 

function build_and_push() {

  # function parameters
  img=$1
  pushit=$2
  echo "\nBUILDING MODULE=$img PUSH=$pushit\n"

  # build the module
  docker build --no-cache -t oodthub/$img .

  # optionally push the module to Docker Hub
  if [ $pushit == '--push' ]; then
       docker push oodthub/$img
  fi

}

# optional 'push' argument
pushit=${1:-false}
 
# this directory
wrkdir=`pwd`

# loop over ordered list of OODT images
images=('oodt-node' 'oodt-filemgr' 'oodt-wmgr' 'oodt-resmgr' 'oodt-fmprod' 'oodt-crawler', 'oodt-rabbitmq')

for img in ${images[*]}; do
   cd "$wrkdir/$img"
   build_and_push $img $pushit
done
