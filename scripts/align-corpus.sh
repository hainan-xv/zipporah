#!/bin/bash

config=$1
aligner=$2
corpusfr=$3
corpusen=$4
alignoutput=$5
tmpfolder=$6

mkdir -p $tmpfolder

. $config

if [ "$aligner" == "fast-align" ]; then
  paste $corpusfr $corpusen | awk -F '\t' '{print $1," ||| ",$2}' > $tmpfolder/pasted

  if [ "$align_job" == "" ] || [ "$align_job" == "1" ]; then
    echo align with 1 job
    $moses/tools/fast_align -i $tmpfolder/pasted -d -o -v > $alignoutput.forward
    $moses/tools/fast_align -i $tmpfolder/pasted -d -o -v -r > $alignoutput.backward
    $moses/tools/atools -i $alignoutput.forward -j $alignoutput.backward -c grow-diag-final-and > $alignoutput
  else
#    shuf $tmpfolder/pasted > $tmpfolder/pasted.shuffed
    echo align with $align_job job

    $ROOT/scripts/run-in-parallel.sh "$ROOT/scripts/fast-align-wrapper.sh $config" $tmpfolder/pasted $alignoutput $align_job $tmpfolder $ROOT

  fi
fi
