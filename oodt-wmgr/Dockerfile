# Docker image for OODT Workflow Manager and Crawler

FROM oodthub/oodt-node:0.3

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# install OODT Workflow Manager service and Crawler executable
COPY pom.xml /tmp/pom.xml
RUN cd /tmp && mvn install

# create symbolic links
RUN cd $OODT_HOME && \
    ln -s ./cas-workflow-${OODT_VERSION} ./cas-workflow && \
    ln -s ./cas-crawler-${OODT_VERSION} ./cas-crawler

# customize properties
COPY conf/workflow.properties $OODT_HOME/cas-workflow/etc/workflow.properties
COPY conf/logging.properties $OODT_HOME/cas-workflow/etc/logging.properties
COPY conf/supervisord.conf /etc/supervisor/supervisord.conf

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
RUN cd /tmp && \
    git clone https://github.com/oodt-cloud/oodt-rabbitmq-clients.git && \
    cd oodt-rabbitmq-clients && \
    cp -R python /usr/local/oodt/rabbitmq

EXPOSE 9001
VOLUME $OODT_STAGING
VOLUME $OODT_ARCHIVE

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
