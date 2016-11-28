#!/bin/sh
# script to test ingestion of a single GenericFile

# create product to ingest and supporting metadata file
cd /tmp
echo 'hello' > /tmp/blah.txt
echo '<cas:metadata xmlns:cas="http://oodt.jpl.nasa.gov/1.0/cas"></cas:metadata>' > /tmp/blah.txt.met

# ingest product
cd /usr/local/oodt/cas-filemgr/bin
./filemgr-client --url http://localhost:9000 --operation --ingestProduct --productName blah.txt --productStructure Flat --productTypeName GenericFile --metadataFile file:///tmp/blah.txt.met --refs file:///tmp/blah.txt

# query for product
./filemgr-client --url http://localhost:9000 --operation --getFirstPage --productTypeName GenericFile

