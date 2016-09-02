# Image containing configuration for LabCAS 'rnaseq' workflow
# This image must extend oodthub/oodt-wmgr because the 'htseq-count' executable
# can only be installed in a system-wide location, not in a separate $PGE_ROOT location
# the Workflow manager needs to have access to htseq-count

FROM oodthub/oodt-wmgr

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# must steup LABCAS environment to use when deploying LabCAS workflows
ENV LABCAS_HOME $OODT_HOME
ENV LABCAS_ARCHIVE $OODT_ARCHIVE
ENV LABCAS_STAGING $OODT_STAGING
ENV LABCAS_CONFIG $OODT_CONFIG

# update libraries
RUN yum -y update && yum clean all

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
RUN mkdir -p $RNASEQ_INSTALL_DIR

# install bowtie2
ENV BT2_VERSION=2.2.9
RUN cd $RNASEQ_INSTALL_DIR && \
    wget https://sourceforge.net/projects/bowtie-bio/files/bowtie2/${BT2_VERSION}/bowtie2-${BT2_VERSION}-linux-x86_64.zip && \
    unzip bowtie2-${BT2_VERSION}-linux-x86_64.zip && \
    rm -f bowtie2-${BT2_VERSION}-linux-x86_64.zip && \
    ln -s ./bowtie2-${BT2_VERSION} ./bowtie2
ENV BT2_HOME $RNASEQ_INSTALL_DIR/bowtie2
ENV PATH $PATH:$BT2_HOME

# install genome index and annotation files
#RUN cd $RNASEQ_INSTALL_DIR && \
#    wget 'ftp://igenome:G3nom3s4u@ussd-ftp.illumina.com/Homo_sapiens/Ensembl/GRCh37/Homo_sapiens_Ensembl_GRCh37.tar.gz' && \
#    tar xvfz Homo_sapiens_Ensembl_GRCh37.tar.gz && \
#    rm -f *.gz
#ENV BOWTIE2_INDEXES $RNASEQ_INSTALL_DIR/Homo_sapiens/Ensembl/GRCh37/Sequence/Bowtie2Index

# install tophat
ENV TOPHAT_VERSION 2.1.1
RUN cd $RNASEQ_INSTALL_DIR && \
    wget https://ccb.jhu.edu/software/tophat/downloads/tophat-${TOPHAT_VERSION}.Linux_x86_64.tar.gz && \
    tar xvfz tophat-${TOPHAT_VERSION}.Linux_x86_64.tar.gz && \
    ln -s ./tophat-${TOPHAT_VERSION}.Linux_x86_64 ./tophat && \
    rm -f *.gz
ENV PATH $PATH:$RNASEQ_INSTALL_DIR/tophat

# install samtools
ENV SAMTOOLS_VERSION 1.3.1
# install utilities
RUN yum -y install bzip2 gcc zlib-devel ncurses-devel ncurses && \
    yum clean all
RUN cd $RNASEQ_INSTALL_DIR && \
    wget https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2 && \
    tar xvf samtools-${SAMTOOLS_VERSION}.tar.bz2 && \
    cd samtools-${SAMTOOLS_VERSION} && \
    make && \
    make prefix=${RNASEQ_INSTALL_DIR}/samtools_install install && \
    rm -f *.bz2
ENV PATH $PATH:$RNASEQ_INSTALL_DIR/samtools_install/bin

# install HTSeq
RUN yum -y install python-devel numpy python-matplotlib gcc-c++ which
RUN cd $RNASEQ_INSTALL_DIR && \
    wget 'https://pypi.python.org/packages/72/0f/566afae6c149762af301a19686cd5fd1876deb2b48d09546dbd5caebbb78/HTSeq-0.6.1.tar.gz#md5=b7f4f38a9f4278b9b7f948d1efbc1f05' && \
    tar xvfz HTSeq-0.6.1.tar.gz && \
    cd  HTSeq-0.6.1 && \
    python setup.py build && \
    python setup.py install

VOLUME $LABCAS_CONFIG/rnaseq
VOLUME $LABCAS_ARCHIVE
VOLUME $PGE_ROOT/rnaseq
