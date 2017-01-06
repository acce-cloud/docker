# Docker image for RabbitMQ server

FROM oodthub/oodt-node

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# install dependencies
RUN yum -y update && \
    yum -y install epel-release && \
    yum -y install logrotate socat && \
    yum clean all

# install zero-dependency Erlang from RabbitMQ
WORKDIR /tmp
ADD https://github.com/rabbitmq/erlang-rpm/releases/download/v1.5.0/erlang-19.2.0-1.el6.x86_64.rpm .
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
COPY conf/rabbitmq-env.conf /etc/rabbitmq/rabbitmq-env.conf

EXPOSE 5672 15672

# copy all scripts to /usr/local/bin
COPY scripts/ /usr/local/bin/

# make python clients available to other containers
COPY clients/ /usr/local/oodt/rabbitmq/
VOLUME /usr/local/oodt/rabbitmq

# start the server
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
