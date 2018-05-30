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
mkdir -p $base/truecaser

(
echo "[step-1] processing train corpus"
if [ -f $clean_stem_good.$input_lang ] && [ -f $clean_stem_good.$output_lang ]; then
  check_equal_lines $clean_stem_good.$input_lang $clean_stem_good.$output_lang
  ln -s $clean_stem_good.$input_lang  $base/corpus/train.$input_lang 2>/dev/null
  ln -s $clean_stem_good.$output_lang $base/corpus/train.$output_lang 2>/dev/null
else
  check_equal_lines $raw_stem_good.$input_lang $raw_stem_good.$output_lang
  for i in $input_lang $output_lang; do
    $ROOT/scripts/raw-to-clean.sh $config $i $raw_stem_good.$i $base/corpus/train.$i $base/corpus/raw_to_clean $base/truecaser/truecase-model 2>&1 > $base/logs/raw-to-clean-good.$i.log
  done
fi 

echo "[step-1] generate alignment"
rm -r -f $base/model

$ROOT/scripts/align-corpus.sh $config $aligner $base/corpus/train.$input_lang $base/corpus/train.$output_lang $alignmentdir/alignment $alignmentdir/tmp/

echo "[step-1] generate dictionaries"

$ROOT/tools/align-to-dict $dict_count_thresh $dict_total_count_thresh $base/corpus/train.$input_lang $base/corpus/train.$output_lang $alignmentdir/alignment $base/model/dict.$input_lang-$output_lang $base/model/dict.$output_lang-$input_lang

)

echo "[step-1] processing dev corpus"
if [ -f $clean_stem_dev.$input_lang ] && [ -f $clean_stem_dev.$output_lang ]; then
  check_equal_lines $clean_stem_dev.$input_lang $clean_stem_dev.$output_lang
  [ ! -f $base/corpus/dev.$input_lang ] && ln -s $clean_stem_dev.$input_lang  $base/corpus/dev.$input_lang
  [ ! -f $base/corpus/dev.$output_lang ] && ln -s $clean_stem_dev.$output_lang $base/corpus/dev.$output_lang
else
  check_equal_lines $raw_stem_good.$input_lang $raw_stem_good.$output_lang
  for i in $input_lang $output_lang; do
    $ROOT/scripts/raw-to-clean.sh $config $i $raw_stem_good.$i $base/corpus/dev.$i $base/corpus/raw_to_clean $base/truecaser/truecase-model 2>&1 > $base/logs/raw-to-clean-good.$i.log
  done
fi 

echo "[step-1] test dictionary on dev data"

cat $base/corpus/dev.$output_lang | $ROOT/scripts/shuf.sh > $base/corpus/dev.shuf.$output_lang

$ROOT/tools/generate-bow-xent $base/model/dict.$output_lang-$input_lang $base/corpus/dev.$output_lang $base/corpus/dev.$input_lang $bow_constant > $base/logs/xent.good.$output_lang-$input_lang &
$ROOT/tools/generate-bow-xent $base/model/dict.$input_lang-$output_lang $base/corpus/dev.$input_lang $base/corpus/dev.$output_lang $bow_constant > $base/logs/xent.good.$input_lang-$output_lang &

$ROOT/tools/generate-bow-xent $base/model/dict.$output_lang-$input_lang $base/corpus/dev.shuf.$output_lang $base/corpus/dev.$input_lang $bow_constant > $base/logs/xent.bad.$output_lang-$input_lang &
$ROOT/tools/generate-bow-xent $base/model/dict.$input_lang-$output_lang $base/corpus/dev.$input_lang $base/corpus/dev.shuf.$output_lang $bow_constant > $base/logs/xent.bad.$input_lang-$output_lang

wait

paste $base/logs/xent.good.* | awk '{print $1+$2}' > $base/logs/xent.good
paste $base/logs/xent.bad.* | awk '{print $1+$2}' > $base/logs/xent.bad

n=`wc $base/logs/xent.good | awk '{print $1}'`

cat $base/logs/xent.{good,bad} | awk '{print NR,$0}' > $base/logs/xent.both
cat $base/logs/xent.both | sort -k2 -g | head -n $n | sort -k1n | grep -n "$n " | sed "s=:= =g" | awk '{print "the quality of the dictionary is", $1 / $2, "out of 1.0"}'

echo "[step-1] train ngrams"
mkdir -p $base/model/ngram

train=$base/corpus/train
for lang in $input_lang $output_lang; do
(  vocab=$base/model/ngram/vocab.$lang
  cat $train.$lang | awk '{for(i=1;i<=NF;i++)print$i}' | sort | uniq -c | sort -n -k1 -r | head -n $word_count | awk '{print$2}' > $vocab
  echo Training LM for $lang
  $moses/bin/lmplz -S 20% --order $ngram_order --limit_vocab_file $vocab --text $train.$lang --arpa $base/model/lm.$lang
  $moses/bin/build_binary $base/model/lm.$lang $base/model/bin.lm.$lang
  ) &
done
wait

echo "[step-1] test lm's on dev data"
modeldir=$working/$id/step-1/model 

for data in dev; do
  cat $base/corpus/$data.$input_lang | python $ROOT/scripts/shuffle-within-lines.py > $base/corpus/$data.shufwords.$input_lang
  cat $base/corpus/$data.$output_lang | python $ROOT/scripts/shuffle-within-lines.py > $base/corpus/$data.shufwords.$output_lang
  cat $base/corpus/$data.shufwords.$output_lang | $ROOT/scripts/shuf.sh > $base/corpus/$data.shufboth.$output_lang

# good fluency bad adequacy
  cat $base/corpus/$data.$input_lang > $base/corpus/bad.$data.$input_lang
  cat $base/corpus/$data.shuf.$output_lang > $base/corpus/bad.$data.$output_lang

# good adequacy bad fluency
  cat $base/corpus/$data.shufwords.$input_lang >> $base/corpus/bad.$data.$input_lang
  cat $base/corpus/$data.shufwords.$output_lang >> $base/corpus/bad.$data.$output_lang

# bad both
  cat $base/corpus/$data.shufwords.$input_lang >> $base/corpus/bad.$data.$input_lang
  cat $base/corpus/$data.shufboth.$output_lang >> $base/corpus/bad.$data.$output_lang
done

for lang in $input_lang $output_lang; do
  ( vocab=$modeldir/ngram/vocab.$lang                                        
    map_unk=`tail -n 1 $vocab`                                                  
    test=$base/corpus/dev
    echo $lang good
    cat $test.$lang | awk -v v=$vocab -v u=$map_unk 'BEGIN{while((getline<v)>0) m[$1]=1;}{for(i=1;i<=NF;i++) {w=$i; if(m[w] !=1) w=u; printf("%s ", w)}; print""}' | $moses/bin/query -v sentence $modeldir/bin.lm.$lang | grep ^Total | awk '{print -$2}' > $base/logs/ngram.good.total.$lang
    cat $test.$lang | awk '{print NF + 1}' > $base/logs/ngram.good.length  # +1 because of the EOS symbol
    paste $base/logs/ngram.good.total.$lang $base/logs/ngram.good.length | awk '{print $1 / $2}' > $base/logs/ngram.good.$lang

    test=$base/corpus/dev.shufwords
    echo $lang bad
    cat $test.$lang | awk -v v=$vocab -v u=$map_unk 'BEGIN{while((getline<v)>0) m[$1]=1;}{for(i=1;i<=NF;i++) {w=$i; if(m[w] !=1) w=u; printf("%s ", w)}; print""}' | $moses/bin/query -v sentence $modeldir/bin.lm.$lang | grep ^Total | awk '{print -$2}' > $base/logs/ngram.bad.total.$lang
    cat $test.$lang | awk '{print NF + 1}' > $base/logs/ngram.bad.length  # +1 because of the EOS symbol
    paste $base/logs/ngram.bad.total.$lang $base/logs/ngram.bad.length | awk '{print $1 / $2}' > $base/logs/ngram.bad.$lang
  ) &
done
wait

paste $base/logs/ngram.good.?? | awk '{print $1+$2}' > $base/logs/ngram.good
paste $base/logs/ngram.bad.??  | awk '{print $1+$2}' > $base/logs/ngram.bad

n=`wc $base/logs/ngram.good | awk '{print $1}'`

cat $base/logs/ngram.{good,bad} | awk '{print NR,$0}' > $base/logs/ngram.both

cat $base/logs/ngram.both | sort -k2 -g | head -n $n | sort -k1n | grep -n "$n " | sed "s=:= =g" | awk '{print "the quality of the lm is", $1 / $2, "out of 1.0"}'

touch $working/$id/.done.1
echo "[step-1] finished."
