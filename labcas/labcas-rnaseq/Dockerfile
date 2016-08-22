# Image containing configuration for LabCAS 'rnaseq' workflow

FROM oodthub/labcas-node

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# checkout LabCAS source 
ENV LABCAS_SRC /tmp
RUN cd $LABCAS_SRC && \
    git clone https://github.com/EDRN/labcas-backend.git && \
    cd labcas-backend && \
    git checkout -b devel origin/devel

# install rnaseq configuration into $LABCAS_HOME/workflows/rnaseq
RUN cd $LABCAS_SRC/labcas-backend && \
    mvn install -Dworkflow=rnaseq

# install rnaseq PGEs into $PGE_ROOT/rnaseq = /usr/local/oodt/pges/rnaseq
ENV RNASEQ_INSTALL_DIR $PGE_ROOT/rnaseq

RUN mkdir -p $RNASEQ_INSTALL_DIR && \
    cp $LABCAS_SRC/labcas-backend/workflows/src/main/resources/rnaseq/pges-test/htseq-count $RNASEQ_INSTALL_DIR/.
ENV PATH $PATH:$RNASEQ_INSTALL_DIR

RUN mkdir -p $RNASEQ_INSTALL_DIR/tophat && \
    cp $LABCAS_SRC/labcas-backend/workflows/src/main/resources/rnaseq/pges-test/tophat $RNASEQ_INSTALL_DIR/tophat/tophat
ENV PATH $PATH:$RNASEQ_INSTALL_DIR/tophat

RUN mkdir -p $RNASEQ_INSTALL_DIR/samtools_install/bin && \
    cp $LABCAS_SRC/labcas-backend/workflows/src/main/resources/rnaseq/pges-test/samtools $RNASEQ_INSTALL_DIR/samtools_install/bin/.
ENV PATH $PATH:$RNASEQ_INSTALL_DIR/samtools_install/bin

VOLUME $LABCAS_CONFIG/rnaseq
VOLUME $LABCAS_ARCHIVE
VOLUME $PGE_ROOT/rnaseq
