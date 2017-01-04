#!/bin/sh
# script to configure the RabbitMQ server for OODT access
# RabbitMQ server must be running

# create non-admin user with all (configure, write, read) permissions on all resources
rabbitmqctl add_user oodt-user changeit
rabbitmqctl set_permissions -p / oodt-user ".*" ".*" ".*"

# create admin user
rabbitmqctl add_user oodt-admin changeit
rabbitmqctl set_user_tags oodt-admin administrator

# delete default user
rabbitmqctl delete_user guest
