#!/bin/bash

orbit=$1
scene=$2
echo "Processing orbit=$orbit scene=$scene"

cd $PGE_DIR
python writeBin.py
