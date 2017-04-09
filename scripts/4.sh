#!/bin/bash

config=$1
. $config


mkdir -p $working/$id/step-4/

#[ "$min_ac_forward" == "" ] && min_ac_forward=`cat $working/$id/step-1/logs/xent.good.$input_lang-$output_lang | awk '{a+=$1}END{print a/NR}'`
#[ "$min_ac_backward" == "" ] && min_ac_backward=`cat $working/$id/step-1/logs/xent.good.$output_lang-$input_lang | awk '{a+=$1}END{print a/NR}'`
#
#[ "$min_lm_fr" == "" ] && min_lm_fr=`cat $working/$id/step-1/logs/ngram.good.$input_lang | awk '{a+=$1}END{print a/NR}'`
#[ "$min_lm_en" == "" ] && min_lm_en=`cat $working/$id/step-1/logs/ngram.good.$output_lang | awk '{a+=$1}END{print a/NR}'`
#
#[ "$max_ac_forward" == "" ]  && max_ac_forward=`cat $working/$id/step-1/logs/xent.bad.$input_lang-$output_lang | awk '{a+=$1}END{print a/NR}'`
#[ "$max_ac_backward" == "" ] && max_ac_backward=`cat $working/$id/step-1/logs/xent.bad.$output_lang-$input_lang | awk '{a+=$1}END{print a/NR}'`
#
#[ "$max_lm_fr" == "" ]       && max_lm_fr=`cat $working/$id/step-1/logs/ngram.bad.$input_lang | awk '{a+=$1}END{print a/NR}'`
#[ "$max_lm_en" == "" ]       && max_lm_en=`cat $working/$id/step-1/logs/ngram.bad.$output_lang | awk '{a+=$1}END{print a/NR}'`
#
#echo flooring...
#echo the tr score cutoff points are $min_ac_forward and $min_ac_backward
#echo the lm score cutoff points are $min_lm_fr and $min_lm_en
#
#echo ceiling... 
#echo the tr score cutoff points are $max_ac_forward and $max_ac_backward
#echo the lm score cutoff points are $max_lm_fr and $max_lm_en

min_ac_forward=0
min_ac_backward=0
min_lm_fr=0
min_lm_en=0
max_ac_forward=1111
max_ac_backward=1111
max_lm_fr=1111
max_lm_en=1111

n=`wc -l $working/$id/step-1/logs/xent.good.$input_lang-$output_lang | awk '{print int($1/10)}'`

[ "$min_ac_forward" == "" ] && min_ac_forward=`cat $working/$id/step-1/logs/xent.good.$input_lang-$output_lang | sort -g | head -n $n | tail -n 1`
[ "$min_ac_backward" == "" ] && min_ac_backward=`cat $working/$id/step-1/logs/xent.good.$output_lang-$input_lang | sort -g | head -n $n | tail -n 1`

[ "$min_lm_fr" == "" ] && min_lm_fr=`cat $working/$id/step-1/logs/ngram.good.$input_lang | sort -g | head -n $n | tail -n 1`
[ "$min_lm_en" == "" ] && min_lm_en=`cat $working/$id/step-1/logs/ngram.good.$output_lang | sort -g | head -n $n | tail -n 1`

[ "$max_ac_forward" == "" ]  && max_ac_forward=`cat $working/$id/step-1/logs/xent.bad.$input_lang-$output_lang | sort -gr | head -n $n | tail -n 1`
[ "$max_ac_backward" == "" ] && max_ac_backward=`cat $working/$id/step-1/logs/xent.bad.$output_lang-$input_lang | sort -gr | head -n $n | tail -n 1`

[ "$max_lm_fr" == "" ]       && max_lm_fr=`cat $working/$id/step-1/logs/ngram.bad.$input_lang | sort -gr | head -n $n | tail -n 1`
[ "$max_lm_en" == "" ]       && max_lm_en=`cat $working/$id/step-1/logs/ngram.bad.$output_lang | sort -gr | head -n $n | tail -n 1`

echo flooring...
echo the tr score cutoff points are $min_ac_forward and $min_ac_backward
echo the lm score cutoff points are $min_lm_fr and $min_lm_en

echo ceiling... 
echo the tr score cutoff points are $max_ac_forward and $max_ac_backward
echo the lm score cutoff points are $max_lm_fr and $max_lm_en

#for data in dev; do
#  score_dir=$working/$id/step-3/$data
#  output_dir=$working/$id/step-4/$data
#
#  mkdir -p $output_dir
#  paste $score_dir/translation.$input_lang-$output_lang $score_dir/translation.$output_lang-$input_lang | awk '{print ($1) + ($2)}' > $output_dir/tr.sum
#
#  echo the following output should be only one line
#  echo BEGIN OF OUTPUT
#  paste $score_dir/translation.$input_lang-$output_lang $score_dir/translation.$output_lang-$input_lang $score_dir/ngram.$input_lang $score_dir/ngram.$output_lang $score_dir/oov-rate.??  | \
#       awk '{print ($1)+($2),"\t",($3)+($4)}' | tee $output_dir/feats.txt | awk '{print NF}' | uniq -c
##       awk '{print $1+$2,$3+$4,exp($1)+exp($2),"\t",exp($3)+exp($4),(($1+$2)/($3+$4)),($3+$4)/($1+$2)}' | tee $output_dir/feats.txt | awk '{print NF}' | uniq -c
##       awk '{print exp($1)+exp($2),"\t",exp($3)+exp($4),(($1+$2)/($3+$4)),($3+$4)/($1+$2)}' | tee $output_dir/feats.txt | awk '{print NF}' | uniq -c
##       awk '{print exp($1),exp($2),exp($3),exp($4),1.0 / (-$5 + 1.000001), 1.5 / (-$6 + 1.000001)}' | tee $output_dir/feats.txt | awk '{print NF}' | uniq -c
#  echo END OF OUTPUT
#done

for data in dev bad bad.dev; do
  score_dir=$working/$id/step-3/$data
  output_dir=$working/$id/step-4/$data

  mkdir -p $output_dir
  paste $score_dir/translation.$input_lang-$output_lang $score_dir/translation.$output_lang-$input_lang | awk '{print ($1) + ($2)}' > $output_dir/tr.sum

  echo the following output should be only one line
  echo BEGIN OF OUTPUT
  paste $score_dir/translation.$input_lang-$output_lang $score_dir/translation.$output_lang-$input_lang $score_dir/ngram.$input_lang $score_dir/ngram.$output_lang $score_dir/oov-rate.??  | \
       awk -v m1=$min_ac_forward -v m2=$min_ac_backward -v m3=$min_lm_fr -v m4=$min_lm_en 'function max(a, b){if(a>b) return a; else return b} {print max($1,m1),max($2,m2),max($3,m3),max($4,m4),$5,$6}' |\
       awk -v m1=$max_ac_forward -v m2=$max_ac_backward -v m3=$max_lm_fr -v m4=$max_lm_en 'function min(a, b){if(a<b) return a; else return b} {print min($1,m1),min($2,m2),min($3,m3),min($4,m4),$5,$6}' |\
       awk '{print ($1)+($2),"\t",($3)+($4)}' | tee $output_dir/feats.txt | awk '{print NF}' | uniq -c
#       awk '{print $1+$2,$3+$4,exp($1)+exp($2),"\t",exp($3)+exp($4),(($1+$2)/($3+$4)),($3+$4)/($1+$2)}' | tee $output_dir/feats.txt | awk '{print NF}' | uniq -c
#       awk '{print exp($1)+exp($2),"\t",exp($3)+exp($4),(($1+$2)/($3+$4)),($3+$4)/($1+$2)}' | tee $output_dir/feats.txt | awk '{print NF}' | uniq -c
#       awk '{print exp($1),exp($2),exp($3),exp($4),1.0 / (-$5 + 1.000001), 1.5 / (-$6 + 1.000001)}' | tee $output_dir/feats.txt | awk '{print NF}' | uniq -c
  echo END OF OUTPUT
done


devbase=$working/$id/step-4/dev
baddevbase=$working/$id/step-4/bad.dev
testbase=$working/$id/step-4/bad

num_gauss=4

scripts/cluster-gmm.sh $config $devbase/feats.txt $num_gauss $devbase/gmm.txt $devbase/gmm/
scripts/cluster-gmm.sh $config $baddevbase/feats.txt $[$num_gauss*3] $baddevbase/gmm.txt $baddevbase/gmm/

scripts/score-gmm.sh $config $devbase/gmm.txt $testbase/feats.txt $testbase/gmm/ > $testbase/good.scores.txt
scripts/score-gmm.sh $config $baddevbase/gmm.txt $testbase/feats.txt $testbase/gmm/ > $testbase/bad.scores.txt

paste $testbase/{good,bad}.scores.txt | awk '{print $1 - 1 * $2}' > $testbase/scores.txt

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
