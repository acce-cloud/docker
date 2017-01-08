#!/usr/bin/env python
# Python workflow producer client:
# sends a message to the RabbitMQ server to start a workflow
# Usage: python workflow_producer.py <workflow_event> [<metadata_key=metadata_value> <metadata_key=metadata_value> ...]

import sys
import os
import pika

# connect to RabbitMQ server: use RABBITMQ_URL or default to guest/guest @ localhost
url = os.environ.get('RABBITMQ_URL', 'amqp://guest:guest@localhost/%2f')
params = pika.URLParameters(url)
params.socket_timeout = 5
connection = pika.BlockingConnection(params)
channel = connection.channel()

# use common OODT workflows Exchange
channel.exchange_declare(exchange='oodt_workflows', type='direct')

# parse command line arguments
if len(sys.argv) < 2:
  raise Exception("Usage: python workflow_producer.py <workflow_event> [<metadata_key=metadata_value> <metadata_key=metadata_value> ...]")
else:
  workflow_event = sys.argv[1]
  message = ' '.join(sys.argv[2:]) or ''

# produce message
# make message persist if RabbitMQ server goes down
channel.basic_publish(exchange='oodt_workflows',
                      routing_key=workflow_event,
                      body=message,
                      properties=pika.BasicProperties(delivery_mode=2) # make message persistent
                      )

print(" [x] Sent workflow message %r: %r" % (workflow_event, message))
connection.close()
