#!/usr/bin/env python
# Python script that sends messages to the RabbitMQ server to trigger execution of OODT workflows.
# Usage: python workflow_producer.py <workflow_event> <number_of_events> [<metadata_key=metadata_value> <metadata_key=metadata_value> ...]
#
# Example: python workflow_producer.py ecostress-L3a-workflow 1 orbit=1 task=L3a scene=7 size=1 heap=1 time=5
#
# To be used together with workflow_consumer.py

import sys
import os
import pika
import logging
import time
import json
import requests
import uuid

logging.basicConfig(level=logging.CRITICAL)


class RabbitmqProducer(object):
    
    EXCHANGE_NAME = 'oodt-exchange' 
    EXCHANGE_TYPE = 'direct'
    PRODUCER_ID = str(uuid.uuid4()) # unique producer identifer
    
    def __init__(self, workflow_event):

        # connect to RabbitMQ server: use RABBITMQ_USER_URL or default to guest/guest @ localhost
        url = os.environ.get('RABBITMQ_USER_URL', 'amqp://guest:guest@localhost/%2f')
        params = pika.URLParameters(url)
        params.socket_timeout = 5
        self.connection = pika.BlockingConnection(params)
        self.channel = self.connection.channel()
        
        # declare exchange
        logging.info('Declaring exchange: %s', self.EXCHANGE_NAME)
        self.channel.exchange_declare(exchange=self.EXCHANGE_NAME,
                                      exchange_type=self.EXCHANGE_TYPE,
                                      durable=True) # survive server reboots

        
        # declare queue, one per workflow
        self.queue_name = workflow_event
        logging.info('Declaring queue: %s', self.queue_name)
        self.channel.queue_declare(queue=self.queue_name, durable=True) # make queue persist server reboots
        
        # bind queue to exchange
        self.routing_key = workflow_event
        logging.info('Binding %s to %s with %s',
                    self.EXCHANGE_NAME, self.queue_name, self.routing_key)
        self.channel.queue_bind(self.queue_name, self.EXCHANGE_NAME, self.routing_key)
        

    def produce(self, msg_dict):
        '''
        Sends a message that will trigger a workflow submission.
        '''
        
        # make message persist if RabbitMQ server goes down
        msg_properties = pika.BasicProperties(app_id=self.PRODUCER_ID,
                                              content_type='application/json',
                                              delivery_mode=2,       # make message persistent
                                              headers=msg_dict)

        self.channel.basic_publish(exchange=self.EXCHANGE_NAME,
                                   routing_key=self.routing_key,
                                   body=json.dumps(msg_dict, ensure_ascii=False),
                                   properties=msg_properties
                                   )

        logging.critical("Sent workflow message %r: %r" % (workflow_event, msg_dict))
        
    def wait_for_completion(self):
        '''
        Method that waits until the number of 'unack messages is 0
        (signaling that all workflows have been completed).
        '''
        
        #url = 'http://oodt-admin:changeit@localhost:15672/api/queues/%2f/test-workflow'
        #resp = requests.get(url=url)
        #data = json.loads(resp.text)
        #print data
        #print data['messages_unacknowledged']
        #print data['messages_ready']
        
        # wait for 'Ready Messages' = 0 (i.e. all messages have been sent)
        num_msgs = -1
        while num_msgs !=0 :
            num_msgs = self.channel.queue_declare(queue=self.queue_name, durable=True, passive=True).method.message_count
            logging.critical("Number of ready messages: %s" % num_msgs)
            time.sleep(1)
            
        # then wait for the 'Unack Messages = 0' (i.e. all messages have been acknowldged)
        num_unack_messages = -1
        # FIXME
        url = 'http://oodt-admin:changeit@localhost:15672/api/queues/%2f/test-workflow'
        while num_unack_messages != 0:
            resp = requests.get(url=url)
            data = json.loads(resp.text)
            num_unack_messages = data['messages_unacknowledged']
            logging.critical("Number of unack messages: %s" % num_unack_messages)
            time.sleep(1)
        
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
        # parse remaining arguments into a dictionary
        msg_dict = {}
        for arg in sys.argv[3:]:
            key, val = arg.split('=')
            msg_dict[key]=val

    # connect to RabbitMQ server on given queue
    rmqProducer = RabbitmqProducer(workflow_event)
    
    # send messages
    for i in range(num_events):
        rmqProducer.produce(msg_dict)
        
    # wait a little for messages to be logged
    #time.sleep(3)
    # then wait for all messages to be acknowledged
    #rmqProducer.wait_for_completion()
    
    # shut down
    rmqProducer.close()