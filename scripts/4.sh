#!/bin/bash

config=$1
. $config


mkdir -p $working/$id/step-4/

[ "$min_ac_forward" == "" ] && min_ac_forward=`cat $working/$id/step-1/logs/xent.good.$input_lang-$output_lang | awk '{a+=$1}END{print a/NR}'`
[ "$min_ac_backward" == "" ] && min_ac_backward=`cat $working/$id/step-1/logs/xent.good.$output_lang-$input_lang | awk '{a+=$1}END{print a/NR}'`

echo the cutoff points are $min_ac_forward and $min_ac_backward

for data in bad dev; do
  score_dir=$working/$id/step-3/$data
  output_dir=$working/$id/step-4/$data

  mkdir -p $output_dir
  echo the following output should be only one line
  echo BEGIN OF OUTPUT
  paste $score_dir/translation.$input_lang-$output_lang $score_dir/translation.$output_lang-$input_lang $score_dir/ngram.?? $score_dir/oov-rate.??  | \
       awk -v m1=$min_ac_forward -v m2=$min_ac_backward 'function max(a, b){if(a>b) return a; else return b} {print max($1,m1),max($2,m2),$3,$4,$5,$6}' |\
       awk '{print exp($1),exp($2),exp($3),exp($4)}' | tee $output_dir/feats.txt | awk '{print NF}' | uniq -c
#       awk '{print exp($1),exp($2),exp($3),exp($4),1.0 / (-$5 + 1.000001), 1.5 / (-$6 + 1.000001)}' | tee $output_dir/feats.txt | awk '{print NF}' | uniq -c
  echo END OF OUTPUT

done

devbase=$working/$id/step-4/dev
testbase=$working/$id/step-4/bad

scripts/cluster-gmm.sh $config $devbase/feats.txt 8 $devbase/gmm.txt $devbase/gmm/

scripts/score-gmm.sh $config $devbase/gmm.txt $testbase/feats.txt $testbase/gmm/ > $testbase/scores.txt

paste $testbase/scores.txt $working/$id/step-2/corpus/bad.clean.{$input_lang,$output_lang} > $working/$id/step-4/pasted.txt

sort -k1 -g -r --parallel=8 -T $working/$id/step-4/tmp $working/$id/step-4/pasted.txt > $working/$id/step-4/pasted.sorted.txt

for i in $num_words_to_select; do
  cat $working/$id/step-4/pasted.sorted.txt | awk -v i=$i 'BEGIN{a=0}{if(a<i){print; a+=NF-1}else{exit}}' > $working/$id/step-4/pasted.sorted.$i.txt
  cat $working/$id/step-4/pasted.sorted.$i.txt | awk -F '\t' '{print $2}' > $working/$id/step-4/selected.$i.$input_lang
  cat $working/$id/step-4/pasted.sorted.$i.txt | awk -F '\t' '{print $3}' > $working/$id/step-4/selected.$i.$output_lang
done
