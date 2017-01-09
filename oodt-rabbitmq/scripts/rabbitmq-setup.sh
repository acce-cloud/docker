#!/bin/sh
# script to configure the RabbitMQ server for OODT access
# RabbitMQ server must be running

# create 'oodt-admin' user if not existing already
rabbitmqctl authenticate_user oodt-admin changeit 2> /dev/null
OUT=$?
if [ $OUT -eq 0 ];then
   echo "User account 'oodt-admin' already existing."
else
   echo "User account 'oodt-admin' not found, creating it."
   rabbitmqctl add_user oodt-admin changeit
   rabbitmqctl set_permissions -p / oodt-admin ".*" ".*" ".*"
   rabbitmqctl set_user_tags oodt-admin administrator
fi

# create 'oodt-user' user if not existing already
rabbitmqctl authenticate_user oodt-user changeit 2> /dev/null
OUT=$?
if [ $OUT -eq 0 ];then
   echo "User account 'oodt-user' already existing."
else
   echo "User account 'oodt-user' not found, creating it."
   rabbitmqctl add_user oodt-user changeit
   rabbitmqctl set_permissions -p / oodt-admin ".*" ".*" ".*"
fi
 
# delete 'guest' user if found
rabbitmqctl authenticate_user guest guest 2> /dev/null
OUT=$?
if [ $OUT -eq 0 ];then
   echo "User account 'guest' found, deleting it."
   rabbitmqctl delete_user guest
else
   echo "User account 'guest' not found."
fi
