#!/bin/sh
# script to build (and optionally push) all OODT Docker images
# Usage:
# ./docker_build_all.sh [--push] 

# optional 'push' argument
pushit=${1:-false}

echo "$pushit"

cd oodt-node
docker build -t oodthub/oodt-node .
if [ $pushit == '--push' ]; then
	docker push oodthub/oodt-node
fi
