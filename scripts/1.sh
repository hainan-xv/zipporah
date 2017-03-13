#!/bin/bash


config=$1
. $config

if [ "$modeldir" != "" ]; then
  echo "Model already provided, skip step-1" && exit;
fi

base=$working/$id/step-1
#[ -d $base ] && rm $base -r
mkdir -p $base
mkdir -p $base/logs

mkdir -p $base/corpus

echo "[step-1] processing good corpus"
if [ -f $clean_stem_good.$input_lang ] && [ -f $clean_stem_good.$output_lang ]; then
  check_equal_lines $clean_stem_good.$input_lang $clean_stem_good.$output_lang
  ln -s $clean_stem_good.$input_lang  $base/corpus/good.clean.$input_lang
  ln -s $clean_stem_good.$output_lang $base/corpus/good.clean.$output_lang
else
  check_equal_lines $raw_stem_good.$input_lang $raw_stem_good.$output_lang
  for i in $input_lang $output_lang; do
    $ROOT/scripts/raw-to-clean.sh $config $i $raw_stem_good.$i $base/corpus/good.clean.$i $base/corpus/raw_to_clean 2>&1 > $base/logs/raw-to-clean-good.$i.log
  done
fi 

for c in good; do
  $moses/scripts/training/clean-corpus-n.perl \
    $base/corpus/$c.clean $input_lang $output_lang \
    $base/corpus/$c.clean.short 6 80
done

rm -r -f $base/model

alignmentdir=$base/model/alignment
$ROOT/scripts/align-corpus.sh $config $aligner $base/corpus/good.clean.short.$input_lang $base/corpus/good.clean.short.$output_lang $alignmentdir/alignment $alignmentdir/tmp/

$ROOT/tools/align-to-dict $dict_count_thresh $base/corpus/good.clean.short.$input_lang $base/corpus/good.clean.short.$output_lang $alignmentdir/alignment $base/model/dict.$input_lang-$output_lang $base/model/dict.$output_lang-$input_lang
for i in $base/model/dict.$input_lang-$output_lang $base/model/dict.$output_lang-$input_lang; do
  mv $i $i.with.num
  cat $i.with.num | grep [a-zA-Z] | grep -v "^[!0-9;%&()‘’+–,?./:\-]" > $i
done

mkdir -p $base/model/ngram

train=$base/corpus/good.clean.short
for lang in $input_lang $output_lang; do
  vocab=$base/model/ngram/vocab.$lang
  cat $train.$lang | awk '{for(i=1;i<=NF;i++)print$i}' | sort | uniq -c | sort -n -k1 -r | head -n $word_count | awk '{print$2}' > $vocab
  echo Training LM for $lang
  $srilm/ngram-count -order $ngram_order -vocab $vocab -text $train.$lang -lm $base/model/lm.$lang -kndiscount

done

touch $working/$id/.done.1
echo "[step-1] finished."
