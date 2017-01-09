#!/bin/bash
# script to start and configure the RabbitMQ server

# start the server
/sbin/service rabbitmq-server start

# configure user accounts (if not done already)
/usr/local/bin/rabbitmq-setup.sh

rabbitmqctl status

# print out the logs
tail -f /var/log/rabbitmq/rabbit*.log
