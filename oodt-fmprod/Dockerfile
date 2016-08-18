# Docker image for OODT File Product server (running within Tomcat)

FROM oodthub/oodt-node

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# Tomcat env
ENV TOMCAT_VERSION 8.5.4
ENV CATALINA_HOME $OODT_HOME/apache-tomcat

RUN wget -O /tmp/apache-tomcat-${TOMCAT_VERSION}.tar.gz http://mirror.reverse.net/pub/apache/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    mkdir -p $OODT_HOME && \
    cd $OODT_HOME && tar xzf /tmp/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    ln -s ${OODT_HOME}/apache-tomcat-${TOMCAT_VERSION} ${OODT_HOME}/apache-tomcat && \
    rm /tmp/apache-tomcat-${TOMCAT_VERSION}.tar.gz

# remove Tomcat example applications
RUN cd ${CATALINA_HOME}/webapps && \
    rm -rf docs examples host-manager manager

# customized copy of context.xml that increases the Tomcat cache to avoid flood of warning messages
COPY context.xml $CATALINA_HOME/conf/context.xml

# install fmprod.war
COPY pom.xml /tmp/pom.xml
RUN cd /tmp && mvn install

EXPOSE 8080

# start Tomcat: 'run' will keep it running in foreground
ENTRYPOINT ["/usr/local/oodt/apache-tomcat/bin/catalina.sh", "run"]
