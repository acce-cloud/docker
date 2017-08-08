#!/usr/bin/env python

import sys
import os
import pika
import xmlrpclib
import time
import threading
import logging

logging.basicConfig(level=logging.INFO, format='(%(threadName)-10s) %(message)s')

STATUS_SUBMITTED="Workflow_Submitted"
STATE_RUNNING = "PGETask_Running"

class WorkflowManagerClient(object):
    '''
    Python client used to interact with a remote Workflow Manager via the XML/RPC API.
    Available methods are defined in Java class org.apache.oodt.cas.workflow.system.XmlRpcWorkflowManager.
    
    IMPORTANT: this class is NOT thread safe because xmlrpclib is NOT thread safe under Pythn 2.7

    IMPORTANT: the workflow manager cannot be queried before the first worklow is submitted,
    because the Lucene index is not initialized. Therefore, this client must first submit a job,
    then start querying the workflow manager for the number of workflow instances that are running.
    '''
    
    def __init__(self, 
                 workflow_event,
                 workflowManagerUrl='http://localhost:9001/',
                 verbose=False,
                 max_num_running_workflow_instances=1):

        # connect to Workflow Manager server
        self.workflowManagerServerProxy = xmlrpclib.ServerProxy(workflowManagerUrl, verbose=verbose)

        logging.info('Workflow event: %s max number of concurrent workflow instances: %s' % (workflow_event, max_num_running_workflow_instances) )
        self.workflow_event = workflow_event
        self.max_num_running_workflow_instances = max_num_running_workflow_instances

        # initialize the number of running workflow instances to 0
        self.num_running_workflow_instances = 0

    def executeWorkflow(self, metadata):
        '''
        Public method that waits for the workflow engine to have a workload below the given threshold
        (i.e. until the number of concurrent workflow instances is less than the configured value),
        then submits a workflow using the specified metadata.
        '''
        
        # wait for workload to be below threshold
        if self.num_running_workflow_instances >= self.max_num_running_workflow_instances:

          while(True):
            try:
              logging.info("Waiting...")
              time.sleep(1)
              response = self.workflowManagerServerProxy.workflowmgr.getNumWorkflowInstancesByStatus(STATE_RUNNING)
              self.num_running_workflow_instances = int( response )
              if self.num_running_workflow_instances < self.max_num_running_workflow_instances:
                 break

            # error in XML/RPC communication
            except Exception as e:
              logging.warn(e.message)

        # submit workflow
        self._submitWorkflow(metadata)
        return STATUS_SUBMITTED

    def _submitWorkflow(self, metadata):
      '''
      Private method that submits the workflow, then updates the number of running instances.
      '''

      try:

        # submit workflow
        logging.info('Submitting workflow %s with metadata %s' % (self.workflow_event, metadata))
        self.workflowManagerServerProxy.workflowmgr.handleEvent(self.workflow_event, metadata)

        # wait a little before querying
        time.sleep(1)

        # update the number of running instances
        response = self.workflowManagerServerProxy.workflowmgr.getNumWorkflowInstancesByStatus(STATE_RUNNING)
        self.num_running_workflow_instances = int( response )

      # error in XML/RPC communication
      except Exception as e:
        logging.warn(e.message)

