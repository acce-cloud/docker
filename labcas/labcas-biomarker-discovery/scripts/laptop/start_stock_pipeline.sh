#!/bin/sh
# Script that starts a Docker container with the Stock Pipeline for biomaker discovery.
# The Docker Engine on the current host must be running.

docker run -it -d -p 9000:9000 -p 8983:8983 -p 9001:9001 --name labcas-biomarker-discovery oodthub/labcas-biomarker-discovery
