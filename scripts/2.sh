#!/bin/bash

function check_equal_lines {
  n1=`wc -l $1 | awk '{print $1}'`
  n2=`wc -l $2 | awk '{print $1}'`
  if [ $n1 -ne $n2 ]; then
    echo "Unequal number of lines: $1 and $2" && exit 1
  fi
}

config=$1
. $config

#set -v
base=$working/$id/step-2
#[ -d $base ] && rm $base -r
mkdir -p $base
mkdir -p $base/logs

mkdir -p $base/corpus

echo "[step-2] processing bad corpus"

if [ -f $clean_stem_bad.$input_lang ] && [ -f $clean_stem_bad.$output_lang ]; then
  check_equal_lines $clean_stem_bad.$input_lang $clean_stem_bad.$output_lang
  ln -s $clean_stem_bad.$input_lang  $base/corpus/bad.$input_lang
  ln -s $clean_stem_bad.$output_lang $base/corpus/bad.$output_lang
else
  check_equal_lines $raw_stem_bad.$input_lang $raw_stem_bad.$output_lang
  for i in $input_lang $output_lang; do
    $ROOT/scripts/raw-to-clean.sh $config $i $raw_stem_bad.$i $base/corpus/bad.long.$i $base/corpus/raw_to_clean 2>&1 > $base/logs/raw-to-clean-bad.$i.log
  done
fi 

for c in bad; do
  $moses/scripts/training/clean-corpus-n.perl \
    $base/corpus/$c.long $input_lang $output_lang \
    $base/corpus/$c 3 80
done

ln -s $working/$id/step-1/corpus/dev.$input_lang $base/corpus
ln -s $working/$id/step-1/corpus/dev.$output_lang $base/corpus

ln -s $working/$id/step-1/corpus/bad.dev.$input_lang $base/corpus
ln -s $working/$id/step-1/corpus/bad.dev.$output_lang $base/corpus

touch $working/$id/.done.2
echo "[step-2] finished."
