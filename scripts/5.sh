#!/bin/bash

config=$1
. $config


mkdir -p $working/$id/step-5/


for data in bad; do
  score_dir=$working/$id/step-3/$data
  output_dir=$working/$id/step-5/$data

  mkdir -p $output_dir
echo " paste $score_dir/ngram.?? $score_dir/translation.??-?? | awk -v w=$ngram_weight -v min_ac=$min_ac 'function max(a, b){if(a>b) return a; else return b}{print w*($1+$2)+max(min_ac,$3+$4)}' > $output_dir/scores.$ngram_weight.txt"
  paste $score_dir/ngram.?? $score_dir/translation.??-?? | awk -v w=$ngram_weight -v min_ac=$min_ac 'function max(a, b){if(a>b) return a; else return b}{print w*($1+$2)+max(min_ac,$3+$4)}' > $output_dir/scores.$ngram_weight.txt
done

testbase=$working/$id/step-5/bad

paste $output_dir/scores.$ngram_weight.txt $working/$id/step-2/corpus/bad.clean.{$input_lang,$output_lang} > $working/$id/step-5/pasted.$ngram_weight.txt

sort -k1 -g --parallel=8 -T $working/$id/step-5/tmp $working/$id/step-5/pasted.$ngram_weight.txt > $working/$id/step-5/pasted.sorted.$ngram_weight.txt

for i in $num_words_to_select; do
  cat $working/$id/step-5/pasted.sorted.$ngram_weight.txt | awk -v i=$i 'BEGIN{a=0}{if(a<i){print; a+=NF-1}else{exit}}' > $working/$id/step-5/pasted.sorted.$ngram_weight.$i.txt
  cat $working/$id/step-5/pasted.sorted.$ngram_weight.$i.txt | awk -F '\t' '{print $2}' > $working/$id/step-5/selected.$ngram_weight.$i.$input_lang
  cat $working/$id/step-5/pasted.sorted.$ngram_weight.$i.txt | awk -F '\t' '{print $3}' > $working/$id/step-5/selected.$ngram_weight.$i.$output_lang
done
