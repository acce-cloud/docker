#!/bin/sh
# node: acce-build1.dyndns.org
# Counts the number of workflows per node, number of tasks per node

containers=$(docker ps | awk '{if(NR>1) print $NF}')
host=$(hostname)

# loop through all containers
for container in $containers
do
  echo "Container: $container"
done


