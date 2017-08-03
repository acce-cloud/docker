# OODT Workflow Manager container that includes the RabbitMQ client
FROM oodthub/oodt-wmgr:0.3

RUN yum -y update && \
    yum -y install gcc zlib-devel openssl openssl-devel && \
    yum clean all

# install Python 2.7
# note: option "--enable-shared" is needed by mod_wsgi, will generate /usr/local/lib/libpython2.7.so.1.0
ENV PYTHON_VERSION 2.7.13
RUN cd /tmp && \
    wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && \
    tar xvfz Python-${PYTHON_VERSION}.tgz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --prefix=/usr/local --enable-shared && \
    make && \
    make altinstall
RUN ln -s /usr/local/bin/python2.7 /usr/local/bin/python
ENV PATH=/usr/local/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/local/bin/python:$LD_LIBRARY_PATH

# install additional core Python packages
RUN cd /tmp && \
    wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py
RUN pip install argparse
RUN pip install pika
RUN pip install requests

# install rabbitmq client module
COPY rabbitmq_clients/ $OODT_HOME/rabbitmq/

# install supervisord configuration to start the rabbitmq client
COPY conf/supervisord-workflow.conf /etc/supervisor/supervisord-workflow.conf

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord-workflow.conf"]
