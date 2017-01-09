#!/usr/bin/env python
# Python workflow producer client:
# sends a message to the RabbitMQ server to start a workflow
# Usage: python workflow_producer.py <workflow_event> <number_of_events> [<metadata_key=metadata_value> <metadata_key=metadata_value> ...]

import sys
import os
import pika
import logging

logging.basicConfig(level=logging.CRITICAL)

class RabbitmqProducer(object):
    
    def __init__(self, workflow_event):

        # connect to RabbitMQ server: use RABBITMQ_URL or default to guest/guest @ localhost
        url = os.environ.get('RABBITMQ_URL', 'amqp://guest:guest@localhost/%2f')
        params = pika.URLParameters(url)
        params.socket_timeout = 5
        self.connection = pika.BlockingConnection(params)
        self.channel = self.connection.channel()
        
        # use default exchange, one queue per workflow
        self.queue_name = workflow_event
        self.channel.queue_declare(queue=self.queue_name, durable=True) # make queue persist server reboots

    def produce(self, message):
        '''
        Sends a message that will trigger a workflow submission.
        '''
        
        # make message persist if RabbitMQ server goes down
        self.channel.basic_publish(exchange='',
                      routing_key=self.queue_name,
                      body=message,
                      properties=pika.BasicProperties(delivery_mode=2) # make message persistent
                      )

        logging.critical("Sent workflow message %r: %r" % (workflow_event, message))
        
        
    def close(self):
        '''
        Closes the connection to the RabbitMQ server.
        '''
        self.connection.close()
        


if __name__ == '__main__':
    ''' Command line invocation method. '''

    # parse command line arguments
    if len(sys.argv) < 3:
      raise Exception("Usage: python workflow_producer.py <workflow_event> <number_of_events> [<metadata_key=metadata_value> <metadata_key=metadata_value> ...]")
    else:
      workflow_event = sys.argv[1]
      num_events = int( sys.argv[2] )
      message = ' '.join(sys.argv[3:]) or ''


    # connect to RabbitMQ server on given queue
    rmqProducer = RabbitmqProducer(workflow_event)
    
    # send messages
    for i in range(num_events):
        rmqProducer.produce(message)
    
    # shut down
    rmqProducer.close()
