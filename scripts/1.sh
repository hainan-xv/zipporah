#!/bin/bash


config=$1
. $config

if [ "$modeldir" != "" ]; then
  echo "Model already provided, skip step-1" && exit;
fi

base=$working/$id/step-1
alignmentdir=$base/model/alignment
#[ -d $base ] && rm $base -r
mkdir -p $base
mkdir -p $base/logs

mkdir -p $base/corpus

echo "[step-1] processing good corpus"
if [ -f $clean_stem_good.$input_lang ] && [ -f $clean_stem_good.$output_lang ]; then
  check_equal_lines $clean_stem_good.$input_lang $clean_stem_good.$output_lang
  ln -s $clean_stem_good.$input_lang  $base/corpus/good.clean.$input_lang 2>/dev/null
  ln -s $clean_stem_good.$output_lang $base/corpus/good.clean.$output_lang 2>/dev/null
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

echo "[step-1] processing dev corpus"

if [ -f $clean_stem_dev.$input_lang ] && [ -f $clean_stem_dev.$output_lang ]; then
  check_equal_lines $clean_stem_dev.$input_lang $clean_stem_dev.$output_lang
  ln -s $clean_stem_dev.$input_lang  $base/corpus/dev.clean.$input_lang
  ln -s $clean_stem_dev.$output_lang $base/corpus/dev.clean.$output_lang
else
  check_equal_lines $raw_stem_dev.$input_lang $raw_stem_dev.$output_lang
  for i in $input_lang $output_lang; do
    $ROOT/scripts/raw-to-clean.sh $config $i $raw_stem_dev.$i $base/corpus/dev.clean.$i $base/corpus/raw_to_clean 2>&1 > $base/logs/raw-to-clean-dev.$i.log
  done
fi 

echo "[step-1] generate alignment"
rm -r -f $base/model

$ROOT/scripts/align-corpus.sh $config $aligner $base/corpus/good.clean.short.$input_lang $base/corpus/good.clean.short.$output_lang $alignmentdir/alignment $alignmentdir/tmp/

$ROOT/tools/align-to-dict $dict_count_thresh $dict_total_count_thresh $base/corpus/good.clean.short.$input_lang $base/corpus/good.clean.short.$output_lang $alignmentdir/alignment $base/model/dict.$input_lang-$output_lang $base/model/dict.$output_lang-$input_lang

#for i in $base/model/dict.$input_lang-$output_lang $base/model/dict.$output_lang-$input_lang; do
#  mv $i $i.with.num
#  cat $i.with.num | grep [a-zA-Z] | grep -v "^[!0-9;%&()‘’+–,?./:\-]" > $i
#done

echo "[step-1] test dictionary on dev data"

cat $base/corpus/dev.clean.$output_lang | ./scripts/shuf.sh > $base/corpus/dev.clean.shuf.$output_lang

../zipporah/tools/generate-bow-scores $base/model/dict.$output_lang-$input_lang $base/corpus/dev.clean.$output_lang $base/corpus/dev.clean.$input_lang > $base/logs/xent.good.$output_lang-$input_lang &
../zipporah/tools/generate-bow-scores $base/model/dict.$input_lang-$output_lang $base/corpus/dev.clean.$input_lang $base/corpus/dev.clean.$output_lang > $base/logs/xent.good.$input_lang-$output_lang &

../zipporah/tools/generate-bow-scores $base/model/dict.$output_lang-$input_lang $base/corpus/dev.clean.shuf.$output_lang $base/corpus/dev.clean.$input_lang > $base/logs/xent.bad.$output_lang-$input_lang &
../zipporah/tools/generate-bow-scores $base/model/dict.$input_lang-$output_lang $base/corpus/dev.clean.$input_lang $base/corpus/dev.clean.shuf.$output_lang > $base/logs/xent.bad.$input_lang-$output_lang

wait


paste $base/logs/xent.good.* | awk '{print $1+$2}' > $base/logs/xent.good
paste $base/logs/xent.bad.* | awk '{print $1+$2}' > $base/logs/xent.bad

n=`wc $base/logs/xent.good | awk '{print $1}'`

cat $base/logs/xent.{good,bad} | awk '{print NR,$0}' > $base/logs/xent.both

cat $base/logs/xent.both | sort -k2 -g | head -n $n | sort -k1n | grep -n "$n " | sed "s=:= =g" | awk '{print "the quality of the dictionary is", $1 / $2, " out of 1.0"}'

echo "[step-1] train ngram on good data"
mkdir -p $base/model/ngram

train=$base/corpus/good.clean.short
for lang in $input_lang $output_lang; do
  vocab=$base/model/ngram/vocab.$lang
  cat $train.$lang | awk '{for(i=1;i<=NF;i++)print$i}' | sort | uniq -c | sort -n -k1 -r | head -n $word_count | awk '{print$2}' > $vocab
  echo Training LM for $lang
#  $srilm/ngram-count -order $ngram_order -vocab $vocab -text $train.$lang -lm $base/model/lm.$lang -kndiscount
  $srilm/ngram-count -order $ngram_order -vocab $vocab -text $train.$lang -lm $base/model/lm.$lang

done

touch $working/$id/.done.1
echo "[step-1] finished."
