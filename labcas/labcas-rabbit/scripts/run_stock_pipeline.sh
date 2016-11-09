#!/bin/bash

cd /restricted/projectnb/pulmarray/rabbit/

mkdir logs

VAR=$RANDOM
NCV=10
PREFIX="stock_pipeline"

for i in `seq 1 $NCV`
do
  ID=$PREFIX"_fold_"$i
  LOG="logs/"$ID".qlog"
  qsub -N $ID -o $LOG scripts/run_stock_pipeline.qsub $i
done
