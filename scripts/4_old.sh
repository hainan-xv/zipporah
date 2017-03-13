#!/bin/bash

config=$1
. $config

score_dir=$working/$id/step-3/

mkdir -p $working/$id/step-4/

paste $score_dir/ngram.?? $score_dir/translation.??-?? | awk -v w=$ngram_weight '{print $1 + $2 + ($3 + $4) * w}' > $working/$id/step-4/score.combine.$ngram_weight

paste $working/$id/step-4/score.combine.$ngram_weight $working/$id/step-2/corpus/bad.clean.?? > $working/$id/step-4/pasted.$ngram_weight
