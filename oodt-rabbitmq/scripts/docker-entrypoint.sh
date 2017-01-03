#!/bin/bash
# script to start the RabbitMQ server and print out the logs

/sbin/service rabbitmq-server start

rabbitmqctl status

tail -f /var/log/rabbitmq/rabbit*.log
