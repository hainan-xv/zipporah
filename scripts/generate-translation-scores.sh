#!/bin/bash

config=$1
in_text=$2
out_text=$3
dict=$4
outfile=$5

. $config

#cat $in_text | $ROOT/tools/bow-translation $dict - | python $ROOT/scripts/unigram-similarity-kl.py - $out_text $bow_constant > $outfile

cat $in_text | $ROOT/tools/generate-bow-scores $dict - $out_text > $outfile #| python $ROOT/scripts/unigram-similarity-kl.py - $out_text $bow_constant > $outfile
