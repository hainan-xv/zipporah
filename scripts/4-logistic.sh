#!/bin/bash

config=$1
. $config

mkdir -p $working/$id/step-4/

devbase=$working/$id/step-4/dev
baddevbase=$working/$id/step-4/bad.dev
testbase=$working/$id/step-4/bad

base=$working/$id/step-4/logistic/

#false && for data in dev bad.dev bad; do
(
for data in dev bad.dev bad; do
  score_dir=$working/$id/step-3/$data
  output_dir=$working/$id/step-4/$data

  mkdir -p $output_dir
  paste $score_dir/translation.$input_lang-$output_lang $score_dir/translation.$output_lang-$input_lang | awk '{print ($1) + ($2)}' > $output_dir/tr.sum

  echo the following output should be only one line
  echo BEGIN OF OUTPUT
  paste $score_dir/translation.$input_lang-$output_lang $score_dir/translation.$output_lang-$input_lang $score_dir/ngram.$input_lang $score_dir/ngram.$output_lang | \
       awk '{print ($1)+($2),"\t",($3)+($4)}' |\
      awk '{a=$1/10;b=$2/10;print a^8,b^8}' | tee $output_dir/feats.txt | awk '{print NF}' | uniq -c
#      awk '{a=$1;b=$2;print a^3,b^3,a^4,b^4}' | tee $output_dir/feats.txt | awk '{print NF}' | uniq -c
#      awk '{a=$1;b=$2;print a,b,a^2,b^2,a^3,b^3,a^4,b^4}' | tee $output_dir/feats.txt | awk '{print NF}' | uniq -c
#      awk '{a=$1;b=$2;print a,b,a^2,b^2,a^3,b^3}' | tee $output_dir/feats.txt | awk '{print NF}' | uniq -c
#      awk '{a=$1;b=$2;print a,b,a^2,b^2,a^3,b^3}' | tee $output_dir/feats.txt | awk '{print NF}' | uniq -c
  echo END OF OUTPUT
done

mkdir -p $base

cat $devbase/feats.txt $baddevbase/feats.txt >  $base/train.feats
cat $devbase/feats.txt    | awk '{print 1}'  >  $base/train.label
cat $baddevbase/feats.txt | awk '{print 0}'  >> $base/train.label

echo python scripts/logistic.py $base/train.feats $base/train.label $testbase/feats.txt $testbase/scores.txt
python scripts/logistic.py $base/train.feats $base/train.label $testbase/feats.txt $testbase/scores.txt
)

paste $working/$id/step-2/corpus/bad.{$output_lang,$input_lang} $testbase/scores.txt | xz > $testbase/corpus.xz

exit

(
paste $testbase/scores.txt $testbase/tr.sum $working/$id/step-2/corpus/bad.{$input_lang,$output_lang} > $working/$id/step-4/pasted.txt
paste $testbase/scores.txt $testbase/feats.txt > $working/$id/step-4/scores.feats

mkdir -p $working/$id/step-4/tmp

sort -k1gr -k2g --parallel=8 -T $working/$id/step-4/tmp $working/$id/step-4/pasted.txt > $working/$id/step-4/pasted.sorted.txt
sort -k1gr -k2g --parallel=8 -T $working/$id/step-4/tmp $working/$id/step-4/scores.feats > $working/$id/step-4/pasted.sorted.feats
)

cat $working/$id/step-4/pasted.sorted.feats | awk 'function e(a,b){c=a-b;return c>0 && c<0.1}{if(e($1,0) || e($1,1) || e($1,-1) || e($1,2) || e($1,-2)) print 10*($2)^0.125,10*($3)^0.125}' > $working/$id/step-4/decision-bdry.feats

n=`cat $working/$id/step-4/pasted.sorted.feats | awk '{if($1<=0){print NR-1;exit}}'`

head -n $n $working/$id/step-4/pasted.sorted.txt | awk -F '\t' '{print $3}' > $working/$id/step-4/selected.auto.$n.$input_lang
head -n $n $working/$id/step-4/pasted.sorted.txt | awk -F '\t' '{print $4}' > $working/$id/step-4/selected.auto.$n.$output_lang
head -n $n $working/$id/step-4/pasted.sorted.feats | awk '{print $2, $3}' > $working/$id/step-4/selected.auto.$n.feats

for i in $num_words_to_select; do
  cat $working/$id/step-4/pasted.sorted.txt | awk -v i=$i 'BEGIN{a=0}{if(a<i){print; a+=NF-2}else{exit}}' > $working/$id/step-4/pasted.sorted.$i.txt
  cat $working/$id/step-4/pasted.sorted.$i.txt | awk -F '\t' '{print $3}' > $working/$id/step-4/selected.$i.$input_lang
  cat $working/$id/step-4/pasted.sorted.$i.txt | awk -F '\t' '{print $4}' > $working/$id/step-4/selected.$i.$output_lang
  num_lines=`wc -l $working/$id/step-4/selected.$i.$output_lang | awk '{print $1}'`
  head -n $num_lines $working/$id/step-4/pasted.sorted.feats | awk '{print $2, $3}' > $working/$id/step-4/selected.$i.feats
done
