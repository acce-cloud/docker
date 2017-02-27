# Python script to drive the ECOSTRESS mock data processing pipeline:
# will start workflows for N orbits and wait until all workflows are completed.
#
# Usage: python ecostress_driver.py <number_of_orbits>

import logging
import sys
import datetime
from rabbitmq_producer import publish_messages, wait_for_queues

LOG_FORMAT = '%(levelname)s: %(message)s'
LOGGER = logging.getLogger(__name__)
LOG_FILE = "rabbitmq_producer.log" # in current directory

NUM_ORBITS_PER_DAY = 15
# there are 9 or 10 scenes in each orbit: 8orbits*9scenes + 7orbits*10scenes = 142scenes
NUM_SCENES_PER_DAY = 142 

FIRST_WORKFLOW = 'ecostress-L3a-workflow' # first workflow to be executed for each scene
FIRST_TASK = 'L3a' # first stask to be executed
SECOND_WORKFLOW = 'ecostress-L3b-workflow' # last workflow to be executed for each scene
THIRD_WORKFLOW = 'ecostress-L4-workflow' # last workflow to be executed for each scene

# benchmarking data

# L3a (pre-processing and reprojection)
# output: 7.9GB
# time: 8mins on eco-scf head node

# L3b (ET with SEBS 100 iterations)
# output: 0.7GB
# time: 18mins on eco-scf compute node

        
def main(number_of_orbits):
    
    logging.basicConfig(level=logging.CRITICAL, format=LOG_FORMAT)
        
    startTime = datetime.datetime.now()
    logging.critical("Start Time: %s" % startTime.strftime("%Y-%m-%d %H:%M:%S") )

    
    # start workflows by sending 1 message for each (orbit, scene) combination
    number_of_scenes_total = 0
    for iorbit in range(1, number_of_orbits+1):
        LOGGER.info("Submitting messages for orbit #: %s" % iorbit)
        
        msg_queue = FIRST_WORKFLOW
        num_msgs = 1
        
        # process 9 or 10 scenes per orbit
        if iorbit % 2 == 1: 
            num_scenes = 9   # odd-number orbits
        else:             
            num_scenes = 10  # even-number orbits
            
        for iscene in range(1, num_scenes + 1):
            msg_dict = { 'orbit':iorbit, 'task':FIRST_TASK, 'scene':iscene }
            publish_messages(msg_queue, num_msgs, msg_dict)
            
            number_of_scenes_total += 1
        
    
    # wait for RabbitMQ server to process all messages in all queues
    wait_for_queues(delay_secs=10)
    
    stopTime = datetime.datetime.now()
    logging.critical("Stop Time: %s" % stopTime.strftime("%Y-%m-%d %H:%M:%S") )
    logging.critical("Elapsed Time: %s secs" % (stopTime-startTime).seconds )

    # write log file (append to existing file)
    with open(LOG_FILE, 'a') as log_file:
        log_file.write('number_of_orbits=%s\t' % number_of_orbits)
        log_file.write('number_of_scenes=%s\t' % number_of_scenes_total)
        log_file.write('elapsed_time_sec=%s\n' % (stopTime-startTime).seconds)
                        

if __name__ == '__main__':
    """ Parse command line arguments. """
    
    if len(sys.argv) < 1:
        raise Exception("Usage: python ecostress_driver.py <number_of_orbits>")
    else:
        number_of_orbits = int( sys.argv[1] )

    main(number_of_orbits)