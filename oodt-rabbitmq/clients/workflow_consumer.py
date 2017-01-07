#!/usr/bin/env python
# Python workflow consumer client:
# receives messages from the RabbitMQ server to start OODT workflows
# Usage: # Usage: python workflow_producer.py <workflow_event>

import sys
import os
import pika
import xmlrpclib

class WorkflowConsumer(object):
    '''
    Python client used to interact with a remote Workflow Manager via the XML/RPC API.
    Available methods are defined in Java class org.apache.oodt.cas.workflow.system.XmlRpcWorkflowManager.
    '''
    
    def __init__(self, 
                 workflow_event,
                 workflowManagerUrl='http://localhost:9001/',
                 verbose=False):
        
        # connect to Workflow Manager server
        self.workflowManagerServerProxy = xmlrpclib.ServerProxy(workflowManagerUrl, verbose=verbose)
        
        # retrieve workflow definition
        self.workflowTasks = self._getWorkflowTasks(workflow_event)
        print 'Workflow tasks: %s' % self.workflowTasks
        
        # RABBITMQ_URL (defaults to guest/guest @ localhost)
        rabbitmqUrl = os.environ.get('RABBITMQ_URL', 'amqp://guest:guest@localhost/%2f')
        
        # connect to RabbitMQ server
        params = pika.URLParameters(rabbitmqUrl)
        params.socket_timeout = 5
        connection = pika.BlockingConnection(params)
        self.channel = connection.channel()
        
        # use common OODT workflows Exchange
        self.channel.exchange_declare(exchange='oodt_workflows', type='direct')

        # declare one temporary queue per consumer
        result = self.channel.queue_declare(exclusive=True)
        self.queue_name = result.method.queue
        
        # bind queue to exchange with appropriate binding key
        self.channel.queue_bind(exchange='oodt_workflows',
                                queue=self.queue_name,
                                routing_key=workflow_event)
        
    def consume(self):
        '''Method to listen for messages from the RabbitMQ server.'''
        
        print('Waiting for workflow events. To exit press CTRL+C')
        self.channel.basic_consume(self._callback, queue=self.queue_name, no_ack=True)
        self.channel.start_consuming()
        


    def _getWorkflowTasks(self, workflow_event):
        '''Retrieve the workflow tasks by the triggering event.'''
        
        workflows =  self.workflowManagerServerProxy.workflowmgr.getWorkflowsByEvent(workflow_event)
        for workflow in workflows:
            tasks = []
            for task in workflow['tasks']:
                tasks.append(task['id'])
            return tasks # assume only one workflow for each event
        
    def _callback(self, ch, method, properties, body):
        '''Callback method invoked when a RabbitMQ message is received.'''

        # FIXME: must parse body to extract metadata
        metadata = { 'Dataset':'abc', 'Project': '123' }
        
        print("Submitting workflow %r: %r" % (method.routing_key, metadata))
        #os.system("cd $OODT_HOME/cas-workflow/bin; ./wmgr-client --url http://localhost:9001 --operation --sendEvent --eventName test-workflow --metaData --key Dataset abc --key Project 123")
        wid = self._executeWorkflow(metadata)
        print('Waiting for completion of workflow: %s' % wid)
        
        # FIXME: wait for completion and send ack

                       
    def _executeWorkflow(self, metadata):
        '''Submits a dynamic workflow using the specified metadata.'''
        
        # FIXME: pass metadata through: s.encode('ascii',errors='ignore')
        return self.workflowManagerServerProxy.workflowmgr.executeDynamicWorkflow(self.workflowTasks, metadata)
            

if __name__ == '__main__':
    ''' Command line invocation method. '''
    
    # parse command line argument
    if len(sys.argv) < 2:
      raise Exception("Usage: python workflow_consumer.py <workflow_event>")
    else:
      workflow_event = sys.argv[1]
      
    # instantiate client 
    consumer = WorkflowConsumer(workflow_event)
    
    # start listening for workflow events
    consumer.consume()
    