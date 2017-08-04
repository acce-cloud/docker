#!/bin/sh
# script to build (and optionally push) all OODT Docker images
# Usage:
# ./docker_pull_all.sh [version] 

function pull() {

  # function parameters
  img=$1
  version=$2
  echo "PULLING IMAGE=$img:$version"

  docker pull oodthub/$img

}

# optional 'push' argument
version=${1:-latest}
 
# this directory
wrkdir=`pwd`

# loop over ordered list of OODT images
images=('oodt-node' 'oodt-filemgr' 'oodt-wmgr' 'oodt-resmgr' 'oodt-fmprod' 'oodt-crawler' 'oodt-rabbitmq')

for img in ${images[*]}; do
   pull $img $version
done
