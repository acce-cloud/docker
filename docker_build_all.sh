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
  cd $img
  docker build --no-cache -t oodthub/$img .
  cd ..

  # optionally push the module to Docker Hub
  if [ $pushit == '--push' ]; then
       docker push oodthub/$img
  fi

}

# optional 'push' argument
pushit=${1:-false}

# loop over ordered list of OODT images
images=('oodt-node' 'oodt-filemgr' 'oodt-wmgr' 'oodt-resmgr' 'oodt-fmprod' 'oodt-crawler')

for img in ${images[*]}; do
   build_and_push $img $pushit
done
