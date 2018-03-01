# Docker image for OOFT Workflow Manager with TensorFlow enabled

ARG ACCE_VERSION=latest
FROM acce/oodt-wmgr:${ACCE_VERSION}
MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>



# install OODT from Workflow Manager image
FROM acce/oodt-wmgr:1.0 as oodt-wmgr

FROM ubuntu

# install JRE
RUN apt-get update
RUN apt-get install -y default-jre
ENV JAVA_HOME=/usr/lib/jvm/default-java

# copy OODT installation (including RabbitMQ client libraries)
ENV OODT_VERSION 1.0
ENV OODT_HOME /usr/local/oodt
ENV FILEMGR_URL http://localhost:9000/
ENV WORKFLOW_URL http://localhost:9001/
ENV RESMGR_URL http://localhost:9002/
ENV OODT_CONFIG ${OODT_HOME}/workflows
ENV PGE_ROOT $OODT_HOME/pges
ENV OODT_ARCHIVE ${OODT_HOME}/archive
ENV OODT_STAGING ${OODT_HOME}/staging

COPY --from=oodt-wmgr $OODT_HOME $OODT_HOME

# install Python
RUN apt-get install -y python2.7

# install pip
RUN apt-get install -y python-pip python-dev build-essential
RUN pip install --upgrade pip 
RUN pip install --upgrade virtualenv

# install TensorFlow
RUN pip install tensorflow

# install additional Python packages needed by OODT
RUN pip install argparse pika requests

# install supervisor
RUN pip install supervisor
COPY --from=oodt-wmgr /etc/supervisor /etc/supervisor
RUN mkdir -p /var/log/supervisor

# startuo OODT processes
CMD ["/usr/local/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
