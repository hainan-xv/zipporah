#!/bin/bash

config=$1
lang=$2
raw=$3
clean=$4
tmpdir=$5
#truecaser=$6

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

#cat $raw | sed "s=????==g" | sed "s=???==g" | sed "s=??==g" | \
#    $moses/scripts/tokenizer/tokenizer.perl -l $lang -no-escape -threads 16 > $clean

cat $raw | sed "s=????==g" | sed "s=???==g" | sed "s=??==g" | \
    $moses/scripts/tokenizer/tokenizer.perl -l $lang -threads 16 > $tmpdir/${file}.tokenized

#$moses/scripts/tokenizer/tokenizer.perl -l $lang \
#    -threads 16                                          \
#    < $raw                                               \
#    > $tmpdir/${file}.tokenized
#

[ -f $truecaser.$lang ] && cp $truecaser.$lang $tmpdir/truecase-model.$lang

if [ ! -f $tmpdir/truecase-model.$lang ]; then
$moses/scripts/recaser/train-truecaser.perl \
    --model $truecaser.$lang --corpus     \
    $tmpdir/${file}.tokenized
fi

$moses/scripts/recaser/truecase.perl \
    --model $truecaser.$lang    \
    < $tmpdir/${file}.tokenized                 \
    > $clean
