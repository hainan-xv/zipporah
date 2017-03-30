#!/bin/bash

config=$1
in_text=$2
out_text=$3
dict=$4
outfile=$5

. $config

kl_const=0.0001
const_2=1

#cat $in_text | $ROOT/tools/bow-translation $dict - | python $ROOT/scripts/unigram-similarity-kl.py - $out_text $bow_constant > $outfile
#KL
#cat $in_text | $ROOT/tools/generate-bow-scores-2 $dict - $out_text 0.0001 1 > $outfile.$kl_const.1

#non-KL
cat $in_text | $ROOT/tools/generate-bow-scores $dict - $out_text   $kl_const $const_2 > $outfile.$kl_const.2

paste $outfile.$kl_const.[12] > $outfile
