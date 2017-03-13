#!/bin/bash

config=$1
model=$2
data=$3
tmpfolder=$4

. $config
mkdir -p $tmpfolder

echo "fake_id [ " > $tmpfolder/feats.ark
cat $data >> $tmpfolder/feats.ark
echo "]" >> $tmpfolder/feats.ark

$clust/classify $model $data | awk '{print $3}' | grep .
