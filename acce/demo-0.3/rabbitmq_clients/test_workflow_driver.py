# Python script to drive the ECOSTRESS mock data processing pipeline:
# will start workflows for N orbits and wait until all workflows are completed.
#
# Usage: python ecostress_driver.py <number_of_orbits>

import logging
import sys
import datetime
import time
from rabbitmq_producer import publish_messages, wait_for_queues

LOG_FORMAT = '%(levelname)s: %(message)s'
LOGGER = logging.getLogger(__name__)
LOG_FILE = "rabbitmq_producer.log" # in current directory
TEST_WORKFLOW = 'test-workflow'

def main(number_of_runs):
    
    logging.basicConfig(level=logging.CRITICAL, format=LOG_FORMAT)
        
    startTime = datetime.datetime.now()
    logging.critical("Start Time: %s" % startTime.strftime("%Y-%m-%d %H:%M:%S") )

    
    # loop over runs=workflows
    for irun in range(1, number_of_runs+1):
        LOGGER.info("Submitting messages for run #: %s" % irun)
        
        msg_queue = TEST_WORKFLOW
        num_msgs = 1
        msg_dict = { 'Dataset':'abc', 'Project':'123', 'Run':irun }
        
        publish_messages(msg_queue, num_msgs, msg_dict)
            
        # wait before submitting the next orbit
        time.sleep(1)
    
    # wait for RabbitMQ server to process all messages in all queues
    wait_for_queues(delay_secs=10)
    
    stopTime = datetime.datetime.now()
    logging.critical("Stop Time: %s" % stopTime.strftime("%Y-%m-%d %H:%M:%S") )
    logging.critical("Elapsed Time: %s secs" % (stopTime-startTime).seconds )

    # write log file (append to existing file)
    with open(LOG_FILE, 'a') as log_file:
        log_file.write('number_of_runs=%s\t' % number_of_runs)
        log_file.write('elapsed_time_sec=%s\n' % (stopTime-startTime).seconds)
                        

if __name__ == '__main__':
    """ Parse command line arguments. """
    
    if len(sys.argv) < 1:
        raise Exception("Usage: python test_workflow_driver.py <number_of_runs>")
    else:
        number_of_runs = int( sys.argv[1] )

    main(number_of_runs)
