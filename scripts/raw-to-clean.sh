#!/bin/bash

config=$1
lang=$2
raw=$3
clean=$4
tmpdir=$5

file=`basename $raw`

echo convert raw corpus to tokenized, true-cased, clean text

if [ ! $# -eq 5 ]; then
  echo $0 config lang raw clean
  exit 1
fi

. $config

set -v

#tmpdir=$working/$id/step-1/corpus/raw-to-clean
#tmpdir=$working/$id/step-1/corpus/raw-to-clean
mkdir -p $tmpdir

$moses/scripts/tokenizer/tokenizer.perl -l $lang \
    -threads 16                                          \
    < $raw                                               \
    > $tmpdir/${file}.tokenized

if [ ! -f $tmpdir/truecase-model.$lang ]; then
$moses/scripts/recaser/train-truecaser.perl \
    --model $tmpdir/truecase-model.$lang --corpus     \
    $tmpdir/${file}.tokenized
fi

$moses/scripts/recaser/truecase.perl \
    --model $tmpdir/truecase-model.$lang    \
    < $tmpdir/${file}.tokenized                 \
    > $clean
