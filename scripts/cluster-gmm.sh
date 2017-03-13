#!/bin/bash

config=$1
data_file=$2
num_gauss=$3
out_param=$4
savefolder=$5

. $config

if [ $# != 5 ]; then
  echo wrong number of parameters. require 5, see $#
  echo $0 data_file num_gauss out_param optional_save_folder
  exit
fi

if [ "$savefolder" == "" ]; then
  savefolder=/tmp/hxu
fi

mkdir -p $savefolder

m=`head -n 1 $data_file | awk '{print NF}'`
n=`wc -l $data_file |awk '{print $1}'`

cat <<EOF > $savefolder/infofile
1
$m
$data_file $n
EOF

#echo $clust/clust $num_gauss $savefolder/infofile $out_param full
$clust/clust $num_gauss $savefolder/infofile $out_param full
