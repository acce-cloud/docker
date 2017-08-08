from __future__ import print_function
import json
from rabbitmq_producer import publish_messages

print('Now loading RabbitMQ producer as AWS Lambda function')

FIRST_WORKFLOW = 'ecostress-L3a-workflow' # first workflow to be executed for each scene
FIRST_TASK = 'L3a' # first stask to be executed

#def lambda_handler(event, context):
def lambda_handler():
    #print("Lambda received event: " + json.dumps(event, indent=2))

    # input data file
    input_data_file = "ecostress_orbit_2_scene_5.dat"
    # ['ecostress', 'orbit', '2', 'scene', '5']
    parts = input_data_file.replace(".dat","").split("_")

    # send message to RabbitMQ server
    msg_queue = FIRST_WORKFLOW
    num_msgs = 1
    iorbit = parts[2]
    iscene = parts[4]
    msg_dict = { 'orbit':iorbit, 'task':FIRST_TASK, 'scene':iscene }
    print("Publishing to queue: %s: message: %s" % (msg_queue, msg_dict))
    publish_messages(msg_queue, num_msgs, msg_dict)
    
    #print("value1 = " + event['key1'])
    #print("value2 = " + event['key2'])
    #print("value3 = " + event['key3'])
    #return event['key1']  # Echo back the first key value
    #raise Exception('Something went wrong')

    return msg_dict

if __name__ == "__main__":
    lambda_handler()
