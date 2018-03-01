# Docker image for RabbitMQ server

FROM centos:6

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# install system utilities
RUN yum -y update && \
    yum -y install gcc \
                   git \
                   lsof \
                   openssl \
                   openssl-devel \
                   tar \
                   unzip \
                   wget \
                   zip \
    && yum clean all

# install dependencies
RUN yum -y update && \
    yum -y install epel-release && \
    yum -y install logrotate socat && \
    yum clean all

# install Python 2.7
ENV PYTHON_VERSION 2.7.13
RUN cd /tmp && \
    wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && \
    tar xvfz Python-${PYTHON_VERSION}.tgz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --prefix=/usr/local && \
    make && \
    make altinstall
RUN ln -s /usr/local/bin/python2.7 /usr/local/bin/python
ENV PATH=/usr/local/bin:$PATH

# install additional core Python packages
RUN cd /tmp && \
    wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py

# install additional core Python packages
RUN pip install argparse
RUN pip install pika
RUN pip install requests

# install rabbitmq client module and dependencies
RUN cd /tmp && \
    git clone https://github.com/oodt-cloud/oodt-rabbitmq-clients.git && \
    cd oodt-rabbitmq-clients && \
    mkdir -p /usr/local/oodt/rabbitmq && \
    cp -R python/* /usr/local/oodt/rabbitmq/.

# install zero-dependency Erlang from RabbitMQ
WORKDIR /tmp
ADD https://github.com/rabbitmq/erlang-rpm/releases/download/v1.5.0/erlang-19.2.0-1.el6.x86_64.rpm .
RUN yum install -y initscripts
RUN rpm -ivh erlang-19.2.0-1.el6.x86_64.rpm

# install RabbitMQ server
# runs as user "rabbitmq"
# database location: /var/lib/rabbitmq/mnesia
# logs location: /var/log/rabbitmq
# env file location: /etc/rabbitmq/rabbitmq-env.conf
# config file location: /etc/rabbitmq/rabbitmq.config 
# start/stop: /sbin/service rabbitmq-server stop/start/etc
# or rabbitmqctl stop/status

ADD https://github.com/rabbitmq/rabbitmq-server/releases/download/rabbitmq_v3_6_6/rabbitmq-server-3.6.6-1.el6.noarch.rpm .
RUN rpm --import https://www.rabbitmq.com/rabbitmq-release-signing-key.asc
RUN rpm -ivh rabbitmq-server-3.6.6-1.el6.noarch.rpm

# enable the Management plugin and web UI
RUN rabbitmq-plugins --offline enable rabbitmq_management

# customize environment
#COPY conf/rabbitmq-env.conf /etc/rabbitmq/rabbitmq-env.conf

# customize configuration to keep connections to consumers alive
# and to use SSL with self-signed certificates (included)
# non-SSL configuration
COPY conf/rabbitmq.config /etc/rabbitmq/rabbitmq.config
# SSL configuration
#COPY conf/rabbitmq-ssl.config /etc/rabbitmq/rabbitmq.config
#COPY conf/certs/ /etc/rabbitmq/certs/

EXPOSE 5672 15672

# copy all scripts to /usr/local/bin
COPY scripts/ /usr/local/bin/

# start the server
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
