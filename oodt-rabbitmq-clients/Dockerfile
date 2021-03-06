# Docker image containing Python libraries for RabbitMQ clients
# (message producers and consumers)

FROM python:2.7

# apply latest security patches
RUN apt-get update && \
    apt-get install -y git

# install python modules
RUN pip install argparse pika requests

# install rabbitmq client module and dependencies
RUN cd /tmp && \
    git clone https://github.com/oodt-cloud/oodt-rabbitmq-clients.git && \
    cd oodt-rabbitmq-clients && \
    mkdir -p /usr/local/oodt/rabbitmq && \
    cp -R python/* /usr/local/oodt/rabbitmq/.

ENV PYTHONPATH=$PYTHONPATH:/usr/local/oodt/rabbitmq

# start RabbitMQ consumer daemon listening to the specific queue
ENTRYPOINT ["python", "/usr/local/oodt/rabbitmq/rabbitmq_consumer.py"]
# startup script arguments: queue_name, max_concurrent_workflows
# will submit workflow requests to $WORKFLOW_URL=http://localhost:9001/
CMD ["test-workflow", "1"]
