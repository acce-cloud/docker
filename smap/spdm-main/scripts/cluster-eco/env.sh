#!/bin/sh
MANAGER_IP=172.30.4.62
MANAGER=eco-p31.tir
NODE1=eco-p32.tir
NODE_LIST="${NODE1}"
SHARED_DIR=/project/dev/clwong/smap/docker-smap
SWARM_NETWORK=spdm-swarm
DB_HOST=jplis-dta-ecostrsd.jpl.nasa.gov
DB_PORT=1521
DB_INSTANT=ECOSTRSD
DB_USER=acce
DB_PASS=
DB_DOMAIN=.JPL.NASA.GOV
alias docker="sudo docker"
