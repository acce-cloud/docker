#!/usr/bin/env python
# Python workflow consumer client:
# receives messages from the RabbitMQ server to start OODT workflows
# Usage: # Usage: python workflow_producer.py <workflow_event>

import pika
import sys
import os

def callback(ch, method, properties, body):
    print("Submitting workflow %r: %r" % (method.routing_key, body))
    os.system("cd $OODT_HOME/cas-workflow/bin; ./wmgr-client --url http://localhost:9001 --operation --sendEvent --eventName test-workflow --metaData --key Dataset abc --key Project 123")

# connect to RabbitMQ server: use RABBITMQ_URL or default to guest/guest @ localhost
url = os.environ.get('RABBITMQ_URL', 'amqp://guest:guest@localhost/%2f')
params = pika.URLParameters(url)
params.socket_timeout = 5
connection = pika.BlockingConnection(params)
channel = connection.channel()

# use common OODT workflows Exchange
channel.exchange_declare(exchange='oodt_workflows', type='direct')

# declare one temporary queue per consumer
result = channel.queue_declare(exclusive=True)
queue_name = result.method.queue

# parse command line argument
if len(sys.argv) < 2:
  raise Exception("Usage: python workflow_consumer.py <workflow_event>")
else:
  workflow_event = sys.argv[1]

# bind queue to exchange with appropriate binding key
channel.queue_bind(exchange='oodt_workflows',
                   queue=queue_name,
                   routing_key=workflow_event)

# start consuming
print('Waiting for workflow events. To exit press CTRL+C')
channel.basic_consume(callback, queue=queue_name, no_ack=True)
channel.start_consuming()
