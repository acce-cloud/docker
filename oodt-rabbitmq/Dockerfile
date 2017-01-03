# Docker image for RabbitMQ server

FROM oodthub/oodt-node

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# install dependencies
RUN yum -y update && \
    yum -y install epel-release && \
    yum -y install logrotate socat python-pip && \
    yum clean all

# install zero-dependency Erlang from RabbitMQ
WORKDIR /tmp
ADD https://github.com/rabbitmq/erlang-rpm/releases/download/v1.5.0/erlang-19.2.0-1.el6.x86_64.rpm .
RUN rpm -ivh erlang-19.2.0-1.el6.x86_64.rpm

# install RabbitMQ server
# runs as user "rabbitmq"
# database location: /var/lib/rabbitmq/mnesia
# logs location: /var/log/rabbitmq
# start/stop: /sbin/service rabbitmq-server stop/start/etc
# or rabbitmqctl stop/status

ADD https://github.com/rabbitmq/rabbitmq-server/releases/download/rabbitmq_v3_6_6/rabbitmq-server-3.6.6-1.el6.noarch.rpm .
RUN rpm --import https://www.rabbitmq.com/rabbitmq-release-signing-key.asc
RUN rpm -ivh rabbitmq-server-3.6.6-1.el6.noarch.rpm

# must increase the number of per-user file descriptors before starting the server
RUN ulimit -S -n 65536

# install python client libraries
RUN pip install pika

EXPOSE 5672 15672

# start the server
COPY scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
