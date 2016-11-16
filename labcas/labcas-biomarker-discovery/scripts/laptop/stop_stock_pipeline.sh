#!/bin/sh
# Script that stops and removed the Docker container with the Stock Pipeline for biomaker discovery.
# Note that all output will be lost as well.

docker stop labcas-biomarker-discovery
docker rm labcas-biomarker-discovery
