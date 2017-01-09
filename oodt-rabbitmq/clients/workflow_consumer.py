#!/usr/bin/env python
# Python workflow consumer client:
# receives messages from the RabbitMQ server to start OODT workflows
# Usage: # Usage: python workflow_consumer.py <workflow_event> <number_of_concurrent_workflows_per_engine>

import sys
import os
import pika
import xmlrpclib
import time
import threading
import logging

logging.basicConfig(level=logging.INFO, format='(%(threadName)-10s) %(message)s')


class WorkflowManagerClient(object):
    '''
    Python client used to interact with a remote Workflow Manager via the XML/RPC API.
    Available methods are defined in Java class org.apache.oodt.cas.workflow.system.XmlRpcWorkflowManager.
    
    IMPORTANT: this class is NOT thread safe because xmlrpclib is NOT thread safe under Pythn 2.7
    '''
    
    def __init__(self, 
                 workflow_event,
                 workflowManagerUrl='http://localhost:9001/',
                 verbose=False):
        
        # connect to Workflow Manager server
        self.workflowManagerServerProxy = xmlrpclib.ServerProxy(workflowManagerUrl, verbose=verbose)
        
        # retrieve workflow definition
        self.workflowTasks = self._getWorkflowTasks(workflow_event)
        logging.info('Workflow tasks: %s' % self.workflowTasks)
    
    def _getWorkflowTasks(self, workflow_event):
        '''Retrieves the workflow tasks by the triggering event.'''
        
        workflows =  self.workflowManagerServerProxy.workflowmgr.getWorkflowsByEvent(workflow_event)
        for workflow in workflows:
            tasks = []
            for task in workflow['tasks']:
                tasks.append(task['id'])
            return tasks # assume only one workflow for each event
        
        
    def executeWorkflow(self, metadata):
        '''
        Public method that submits a workflow using the specified metadata,
        then blocks until its completion.
        '''
        
        # submit workflow
        wInstId = self.workflowManagerServerProxy.workflowmgr.executeDynamicWorkflow(self.workflowTasks, metadata)

        # wait for workflow completion
        return self._waitForWorkflowCompletion(wInstId)
        
    
    def _waitForWorkflowCompletion(self, wInstId):
        ''' Monitors a workflow instance until it completes.'''
    
        # wait for the server to instantiate this workflow before querying it
        time.sleep(2) 
    
        # now use the workflow instance id to check for status, wait until completed
        running_status  = ['CREATED', 'QUEUED', 'STARTED', 'PAUSED']
        pge_task_status = ['STAGING INPUT', 'BUILDING CONFIG FILE', 'PGE EXEC', 'CRAWLING']
        finished_status = ['FINISHED', 'ERROR', 'METMISS']
        status = 'UNKNOWN'
        while (True):
            response = self.workflowManagerServerProxy.workflowmgr.getWorkflowInstanceById(wInstId)
            status = response['status']
            if status in running_status or status in pge_task_status:
                logging.debug('Workflow instance=%s running with status=%s' % (wInstId, status))
                time.sleep(1)
            elif status in finished_status:
                logging.info('Workflow instance=%s ended with status=%s' % (wInstId, status))
                break
            else:
                logging.warn('UNRECOGNIZED WORKFLOW STATUS: %s' % status)
                break
        return status
    

class RabbitmqConsumer(threading.Thread):
    '''
    Python client that consumes messages from the RabbitMQ server,
    and triggers execution of workflows through the WorkflowManagerClient.
    This class listens for messages in a separate thread.
    '''
    
    def __init__(self, workflow_event, wmgrClient, 
                 group=None, target=None, name=None, verbose=None): # Thread parent class arguments
        
        # initialize Thread
        threading.Thread.__init__(self, group=group, target=target, name=name, verbose=verbose)
        
        # workflow manager client
        self.wmgrClient = wmgrClient
                
        # RABBITMQ_URL (defaults to guest/guest @ localhost)
        rabbitmqUrl = os.environ.get('RABBITMQ_URL', 'amqp://guest:guest@localhost/%2f')
        
        # connect to RabbitMQ server
        params = pika.URLParameters(rabbitmqUrl)
        params.socket_timeout = 5
        connection = pika.BlockingConnection(params)
        self.channel = connection.channel()
        
        # connect to queue for given workflow
        self.queue_name = workflow_event
        self.channel.queue_declare(queue=self.queue_name, durable=True)
                 
    def run(self):
        logging.debug("Listening for messages...")
        self._consume()       
        
    def _consume(self):
        '''Method to listen for messages from the RabbitMQ server.'''
        
        # process 1 message at a time from this queue
        self.channel.basic_qos(prefetch_count=1)
        
        self.channel.basic_consume(self._callback, queue=self.queue_name) # no_ack=False
        self.channel.start_consuming()
        
        
    def _callback(self, ch, method, properties, body):
        '''Callback method invoked when a RabbitMQ message is received.'''

        # parse message body into metadata dictionary
        # from: 'Dataset=abc Project=123'
        # to: { 'Dataset':'abc', 'Project': '123' }
        metadata = dict(word.split('=') for word in body.split())
                
        # submit workflow, then wait for its completeion
        logging.info("Received message: %r: %r, submitting workflow..." % (method.routing_key, metadata))
        #time.sleep(10)
        status = self.wmgrClient.executeWorkflow(metadata)      
        logging.info('Worfklow ended with status: %s' % status)
        
        # send acknowledgment to RabbitMQ server
        ch.basic_ack(delivery_tag = method.delivery_tag)


if __name__ == '__main__':
    ''' Command line invocation method. '''
    
    # parse command line argument
    if len(sys.argv) < 3:
      raise Exception("Usage: python workflow_consumer.py <workflow_event> <number_of_concurrent_workflows_per_engine>")
    else:
      workflow_event = sys.argv[1]
      num_workflow_clients = int(sys.argv[2])
      
    # instantiate N RabbitMQ clients
    for i in range(num_workflow_clients):
        
        # instantiate Workflow Manager client
        # IMPORTANT: xmlrpclib is NOT thread safe in Python 2.7
        # so must create one WorkflowManagerClient to be used in each thread
        wmgrClient = WorkflowManagerClient(workflow_event)
        
        rmqConsumer = RabbitmqConsumer(workflow_event, wmgrClient)
    
        # start listening for workflow events
        rmqConsumer.start()
    
    logging.info('Waiting for workflow events. To exit press CTRL+Z')
    