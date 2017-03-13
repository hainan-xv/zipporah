#!/bin/bash

config=$1
. $config


mkdir -p $working/$id/step-7/


for data in bad; do
  score_dir=$working/$id/step-3/$data
  output_dir=$working/$id/step-7/$data

  mkdir -p $output_dir
  paste $score_dir/ngram.?? $score_dir/translation.??-?? $score_dir/oov-rate.?? | awk -v w=$oov_weight '{print ($1+$2)+($3+$4)+w*($5+$6)}' > $output_dir/scores.txt
done

testbase=$working/$id/step-7/bad

paste $output_dir/scores.txt $working/$id/step-2/corpus/bad.clean.?? > $working/$id/step-7/pasted.txt

sort -k1 -g --parallel=8 -T $working/$id/step-7/tmp $working/$id/step-7/pasted.txt > $working/$id/step-7/pasted.sorted.txt

for i in $num_words_to_select; do
  cat $working/$id/step-7/pasted.sorted.txt | awk -v i=$i 'BEGIN{a=0}{if(a<i){print; a+=NF-1}else{exit}}' > $working/$id/step-7/pasted.sorted.$i.txt
  cat $working/$id/step-7/pasted.sorted.$i.txt | awk -F '\t' '{print $2}' > $working/$id/step-7/selected.$i.$input_lang
  cat $working/$id/step-7/pasted.sorted.$i.txt | awk -F '\t' '{print $3}' > $working/$id/step-7/selected.$i.$output_lang
done

