#!/bin/bash

config=$1
. $config

mkdir -p $working/$id/step-4/

for data in dev bad bad.dev; do
  score_dir=$working/$id/step-3/$data
  output_dir=$working/$id/step-4/$data

  mkdir -p $output_dir
  paste $score_dir/translation.$input_lang-$output_lang $score_dir/translation.$output_lang-$input_lang | awk '{print ($1) + ($2)}' > $output_dir/tr.sum

  echo the following output should be only one line
  echo BEGIN OF OUTPUT
  paste $score_dir/translation.$input_lang-$output_lang $score_dir/translation.$output_lang-$input_lang $score_dir/ngram.$input_lang $score_dir/ngram.$output_lang | \
       awk '{print ($1)+($2),"\t",($3)+($4)}' | tee $output_dir/feats.txt | awk '{print NF}' | uniq -c
  echo END OF OUTPUT
done

devbase=$working/$id/step-4/dev
baddevbase=$working/$id/step-4/bad.dev
testbase=$working/$id/step-4/bad

base=$working/$id/step-4/logistic/
mkdir -p $base

cat $devbase/feats.txt $baddevbase/feats.txt >  $base/train.feats
cat $devbase/feats.txt    | awk '{print 1}'  >  $base/train.label
cat $baddevbase/feats.txt | awk '{print 0}'  >> $base/train.label

python scripts/logistic.py $base/train.feats $base/train.label $testbase/feats.txt $testbase/scores.txt

#num_gauss=4
#
#scripts/cluster-gmm.sh $config $devbase/feats.txt $num_gauss $devbase/gmm.txt $devbase/gmm/
#scripts/cluster-gmm.sh $config $baddevbase/feats.txt $[$num_gauss*3] $baddevbase/gmm.txt $baddevbase/gmm/
#
#scripts/score-gmm.sh $config $devbase/gmm.txt $testbase/feats.txt $testbase/gmm/ > $testbase/good.scores.txt
#scripts/score-gmm.sh $config $baddevbase/gmm.txt $testbase/feats.txt $testbase/gmm/ > $testbase/bad.scores.txt
#
#paste $testbase/{good,bad}.scores.txt | awk '{print $1 - 1 * $2}' > $testbase/scores.txt
#
#cat $testbase/scores.txt | head -n 155362 > $testbase/scores.good.txt
#cat $testbase/scores.txt | tail -n 155362 > $testbase/scores.bad2.txt
#cat $testbase/scores.txt | head -n -155362 | tail -n 155362 > $testbase/scores.bad1.txt
#
#echo both
#cat $working/$id/step-4/bad/scores.txt | awk '{print $1, NR}' | sort -k1gr | head -n 155362 | sort -k2g | grep 155362$ -n | awk -F ":" '{print $1/155362}'
#
#echo first
#cat $working/$id/step-4/bad/scores.{good,bad1}.txt | awk '{print $1, NR}' | sort -k1gr | head -n 155362 | sort -k2g | grep 155362$ -n | awk -F ":" '{print $1/155362}'
#
#echo second
#cat $working/$id/step-4/bad/scores.{good,bad2}.txt | awk '{print $1, NR}' | sort -k1gr | head -n 155362 | sort -k2g | grep 155362$ -n | awk -F ":" '{print $1/155362}'
#
#exit

#paste $testbase/scores.txt $working/$id/step-2/corpus/bad.clean.{$input_lang,$output_lang} > $working/$id/step-4/pasted.txt
paste $testbase/scores.txt $testbase/tr.sum $working/$id/step-2/corpus/bad.clean.{$input_lang,$output_lang} > $working/$id/step-4/pasted.txt

sort -k1gr -k2g --parallel=8 -T $working/$id/step-4/tmp $working/$id/step-4/pasted.txt > $working/$id/step-4/pasted.sorted.txt

for i in $num_words_to_select; do
  cat $working/$id/step-4/pasted.sorted.txt | awk -v i=$i 'BEGIN{a=0}{if(a<i){print; a+=NF-2}else{exit}}' > $working/$id/step-4/pasted.sorted.$i.txt
  cat $working/$id/step-4/pasted.sorted.$i.txt | awk -F '\t' '{print $3}' > $working/$id/step-4/selected.$i.$input_lang
  cat $working/$id/step-4/pasted.sorted.$i.txt | awk -F '\t' '{print $4}' > $working/$id/step-4/selected.$i.$output_lang
done
