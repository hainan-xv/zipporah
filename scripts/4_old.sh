#!/bin/bash

config=$1
. $config

score_dir=$working/$id/step-3/

mkdir -p $working/$id/step-5/

paste $score_dir/ngram.?? $score_dir/translation.??-?? | awk -v w=$ngram_weight '{print $1 + $2 + ($3 + $4) * w}' > $working/$id/step-5/score.combine.$ngram_weight

paste $working/$id/step-5/score.combine.$ngram_weight $working/$id/step-2/corpus/bad.clean.?? > $working/$id/step-5/pasted.$ngram_weight

sort -k1 -g -r --parallel=8 -T $working/$id/step-5/tmp $working/$id/step-5/pasted.$ngram_weight > $working/$id/step-5/pasted.sorted.$ngram_weight

for i in $num_words_to_select; do
  cat $working/$id/step-5/pasted.sorted.$ngram_weight | awk -v i=$i 'BEGIN{a=0}{if(a<i){print; a+=NF-1}else{exit}}' > $working/$id/step-5/pasted.sorted.$ngram_weight.$i.txt
  cat $working/$id/step-5/pasted.sorted.$ngram_weight.$i.txt | awk -F '\t' '{print $2}' > $working/$id/step-4/selected.$ngram_weight.$i.$input_lang
  cat $working/$id/step-5/pasted.sorted.$ngram_weight.$i.txt | awk -F '\t' '{print $3}' > $working/$id/step-4/selected.$ngram_weight.$i.$output_lang
done
